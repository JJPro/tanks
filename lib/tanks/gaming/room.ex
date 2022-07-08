defmodule Tanks.Gaming.Room do
  @moduledoc """
  # Functions To Update Room Struct

  - CRUD of players in the room
  - starts or terminates the game for the room
  """
  alias __MODULE__
  alias Tanks.Gaming.Artifacts.Player
  alias Tanks.Gaming.{Game, GameServer}
  alias Tanks.Accounts.User

  defstruct name: "", players: [], game: nil

  @type t :: %Room{
          name: String.t(),
          players: [Player.t()],
          # game: the GameServer process pid
          game: pid() | nil
        }
  @type lobby_view :: %{
          name: String.t(),
          status: atom()
        }

  @sprites [
    "/images/tank-cyan.png",
    # "/images/tank-red.png",
    "/images/tank-army-green.png",
    "/images/tank-yellow.png",
    "/images/tank-khaki.png",
    "/images/tank-green.png",
    "/images/tank-magenta.png",
    "/images/tank-purple.png"
  ]

  @spec new(String.t(), %User{}) :: t()
  def new(name, hostuser) do
    host = %Player{
      user: hostuser,
      sprite: hd(@sprites)
    }

    %Room{
      name: name,
      players: [host]
    }
  end

  @spec add_player(t(), %User{}) :: {:ok, t()} | {:error, String.t()}
  def add_player(room = %Room{}, user) do
    with nil <- find_player_of_user(room, user),
         :open <- get_status(room) do
      sprites_taken =
        for %Player{} = player <- room.players do
          player.sprite
        end

      sprite =
        @sprites
        |> Enum.shuffle()
        |> Enum.find(&(&1 not in sprites_taken))

      new_player = %Player{
        user: user,
        sprite: sprite
      }

      {:ok, %{room | players: [new_player | room.players]}}
    else
      %Player{} -> {:ok, room}
      :full -> {:error, "room is full"}
      :in_game -> {:error, "game already started"}
    end
  end

  @doc """
  Removes player of user from room.

  Returns
    - {:ok, %Room{}} if there are still players in the room
    - {:empty_room, nil} if all players have left the room
  """
  @spec remove_player(t(), %User{}) :: {:ok, t()} | {:empty_room, nil}
  def remove_player(room = %Room{}, user) do
    new_players = Enum.filter(room.players, &(&1.user != user))

    if List.first(new_players) do
      {:ok, %{room | players: new_players}}
    else
      {:empty_room, nil}
    end
  end

  @spec get_status(t()) :: :open | :full | :in_game
  def get_status(room) do
    cond do
      room.game -> :in_game
      length(room.players) == 4 -> :full
      true -> :open
    end
  end

  @doc """
  Player toggles the "Ready" button
  """
  @spec player_toggle_ready(t(), %User{}) :: {:ok, t()}
  def player_toggle_ready(room, user) do
    players =
      Enum.map(room.players, fn
        player when player.user == user -> %{player | ready?: !player.ready?}
        player -> player
      end)

    {:ok, %{room | players: players}}
  end

  @spec start_game(t()) :: {:ok, t()} | {:error, %{reason: String.t()}}
  def start_game(room = %Room{}) do
    cond do
      length(room.players) < 2 ->
        {:error, %{reason: "not enough players, needs at least 2 players to start"}}

      Enum.any?(room.players, &(!&1.ready?)) ->
        {:error, %{reason: "players are not ready"}}

      true ->
        {:ok, pid} =
          DynamicSupervisor.start_child(
            Tanks.GameServerSupervisor,
            {GameServer, {Game.new(room.players), room.name}}
          )

        {:ok, %{room | game: pid}}
    end
  end

  @doc """
  Cleanup work for Game Over event.
  """
  @spec end_game(t()) :: {:ok, t()}
  def end_game(room) do
    players = Enum.map(room.players, fn p -> %{p | ready?: false} end)
    {:ok, %{room | players: players, game: nil}}
  end

  @doc """
  Gets the host of given room.
  """
  @spec host(t()) :: Player.t()
  def host(room) do
    List.last(room.players)
  end

  @spec user_role(t(), number()) :: :host | :player | :observer
  def user_role(room, user_id) do
    cond do
      host(room).user.id === user_id -> :host
      Enum.any?(room.players, fn p -> p.user.id === user_id end) -> :player
      true -> :observer
    end
  end

  @doc """
  Gets the data format that is required to sent to the lobby topic
  """
  @spec lobby_view(t()) :: lobby_view()
  def lobby_view(room) do
    %{
      name: room.name,
      status: get_status(room)
    }
  end

  # Finds the player for given user object, in room
  @spec find_player_of_user(t(), %User{}) :: Player.t() | nil
  defp find_player_of_user(room, user) do
    Enum.find(room.players, &(&1.user == user))
  end
end

defimpl Jason.Encoder, for: Tanks.Gaming.Room do
  def encode(%Tanks.Gaming.Room{} = room, opts) do
    room =
      room
      |> Map.take([:name, :players])
      |> Map.merge(%{
        status: Tanks.Gaming.Room.get_status(room)
      })

    Jason.Encode.map(room, opts)
  end
end
