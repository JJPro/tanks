defmodule Tanks.Gaming.GameServer do
  @moduledoc """
  The Game Loop process.

  Example:
    {:ok, pid} = GameServer.start_link(game, "room name")
    GameServer.move(pid, uid, :right)
    GameServer.fire(pid, uid)

  ## Broadcast Messages At Various Stages Of The Game Loop

  The Game Loop broadcasts the following messages at various stages,
  those messages are supposed to be handled by the topics' PubSub subscribers (e.g. channel client JS).

  | stage     | event       | pubsub topics         | payload                                 |
  | --------- | ----------- | --------------------- | --------------------------------------- |
  | gamestart | gamestart   | room:room_name        | -                                       |
  | the loop  | game_tick   | game:room_name        | %{game: game}                           |
  | gameover  | gameover    | game:room_name        | -                                       |
  | gameover  | room_change | lobby, room:room_name | %{room: Room.lobby_view}, %{room: room} |
  | crash     | gamecrash   | game:room_name        | -                                       |
  | crash     | room_change | lobby, room:room_name | %{room: Room.lobby_view}, %{room: room} |
  """
  use GenServer, restart: :temporary

  alias Tanks.Gaming.{Game, Room}
  alias Tanks.Store.RoomStore

  # game loop update interval, in milliseconds
  @interval 35

  @type state :: {room_name :: String.t(), game :: Game.t() | nil}

  @spec start_link({Game.t(), String.t()}) :: {:ok, GenServer.server()}
  def start_link({game, room_name}) do
    {:ok, pid} = GenServer.start_link(__MODULE__, {room_name, game})
    Process.send(pid, :loop, [])

    # broadcast gamestart event to room
    #   this is used for:
    #     - initiate game start countdown
    :ok = broadcast!(:room, room_name, "gamestart", %{})
    {:ok, pid}
  end

  @spec fire(GenServer.server(), integer()) :: :ok
  def fire(server, player_uid) do
    GenServer.cast(server, {:fire, player_uid})
  end

  @spec move(GenServer.server(), integer(), :up | :down | :left | :right) :: :ok
  def move(server, player_uid, direction) do
    GenServer.cast(server, {:move, player_uid, direction})
  end

  @impl true
  @spec init(state()) :: {:ok, state()}
  def init(state) do
    {:ok, state}
  end

  @doc """
  Handles game crash.

  When game crash:
  1. broadcast to game players
  2. update roomstore
  3. broadcast room_change event to room and lobby
  """
  @impl true
  def terminate(reason, {room_name, _game}) when reason !== :normal do
    room = RoomStore.get(room_name)
    {:ok, room} = Room.end_game(room)
    :ok = RoomStore.put(room_name, room)
    broadcast!(:game, room_name, "gamecrash", %{})
    broadcast!(:room, room_name, "room_change", %{room: room})
    broadcast!(:lobby, "room_change", %{room: Room.lobby_view(room)})
  end

  @doc """
  Game Loop

  @return:
    - {:noreply, state()}: updates the game state
    - {:stop, :normal, state()}: signal GenServer process to terminate, on "gameover" event
  """
  @impl true
  @spec handle_info(:loop, state()) :: {:noreply, state()} | {:stop, :normal, state()}
  def handle_info(:loop, {room_name, game} = state) do
    # WARN Hope this works with `self`
    Process.send_after(self(), :loop, @interval)

    # Step the game iff current state has missiles in map (to reserve messaging frequency)
    #   Broadcast new state to players
    # Check if gameover and broadcast "gameover" event if is
    with true <- length(game.missiles) > 0,
         game = Game.step(game),
         :ok <- broadcast!(:game, room_name, "game_tick", %{game: game}),
         true <- Game.gameover?(game) do
      broadcast!(:game, room_name, "gameover", %{game: game})

      # terminate game, update room, and broadcast new room status to room channels and the lobby
      room = RoomStore.get(room_name)
      {:ok, room} = Room.end_game(room)
      :ok = RoomStore.put(room_name, room)
      broadcast!(:room, room_name, "room_change", %{room: room})
      broadcast!(:lobby, "room_change", %{room: Room.lobby_view(room)})

      # signal GenServer process to terminate
      {:stop, :normal, {room_name, nil}}
    else
      _ -> {:noreply, state}
    end
  end

  @spec broadcast!(:game | :room | :lobby, String.t(), String.t(), term()) :: :ok | no_return()
  defp broadcast!(namespace, subtopic \\ "", event, data)

  defp broadcast!(:lobby, _, event, data) do
    TanksWeb.Endpoint.broadcast!("lobby", event, data)
  end

  defp broadcast!(namespace, subtopic, event, data) do
    TanksWeb.Endpoint.broadcast!(topic(namespace, subtopic), event, data)
  end

  # Gets broadcasting topic
  @spec topic(:game | :room | :lobby, String.t()) :: String.t()
  defp topic(type, room_name) when is_atom(type) do
    to_string(type) <> ":" <> room_name
  end

  @impl true
  def handle_cast({:fire, player_uid}, {room_name, game}) do
    {:noreply, {room_name, Game.fire(game, player_uid)}}
  end

  @impl true
  def handle_cast({:move, player_uid, direction}, {room_name, game})
      when direction in [:up, :down, :left, :right] do
    {:noreply, {room_name, Game.move(game, player_uid, direction)}}
  end
end
