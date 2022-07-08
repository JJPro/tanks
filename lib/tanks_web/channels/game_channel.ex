defmodule TanksWeb.GameChannel do
  @moduledoc """
  ## GameChannel

  The Game Channel handles live communications between game clients.

  ## Topic

  game:<room_name>

  The topic of the game is named after name of its belonging room

  ## Events

  The channel is responsible for handling events emitted from its clients,
  and for forwarding broadcasting messages, initiated from various places of the app, to its clients.

  ### Incomming Events From Its Clients

  | event | payload        |
  | ----- | -------------- |
  | fire  | -              |
  | move  | %{"direction"} |

  ### Forwarded Broadcasts To Clients (To Be Handled in Clients)

  Broadcasted events are events emitted from other places of the application,
  and needs to be handled by the client side (JS).
  This module simply forwards those broadcasting messages to user clients,
  and the clients (JS) needs to handle them.

  | event     | payload       |
  | --------- | ------------- |
  | game_tick | %{game: game} |
  | gameover  | %{game: game} |

  """
  use TanksWeb, :channel
  alias Tanks.Gaming.{GameServer, Game, Room}
  alias Tanks.Store.RoomStore

  intercept ["gameover"]

  @impl true
  def join("game:" <> room_name, _payload, socket) do
    with room = %Room{} <- RoomStore.get(room_name),
         game_pid when is_pid(game_pid) <- room.game,
         true <- Process.alive?(game_pid) do
      role =
        cond do
          Enum.any?(room.players, fn p -> p.user.id === socket.assigns.user_id end) -> :player
          true -> :observer
        end

      {:ok,
       %{
         game: GameServer.get_state(game_pid),
         user_id: socket.assigns.user_id,
         role: role
       }, assign(socket, :game, game_pid)}
    else
      _ -> {:error, %{reason: "terminated"}}
    end
  end

  @impl true
  def handle_in("fire", _payload, socket) do
    :ok =
      GameServer.fire(
        socket.assigns.game,
        socket.assigns.user_id
      )

    {:noreply, socket}
  end

  @impl true
  def handle_in("move", %{"direction" => direction}, socket) do
    :ok =
      GameServer.move(
        socket.assigns.game,
        socket.assigns.user_id,
        String.to_atom(direction)
      )

    {:noreply, socket}
  end

  @impl true
  def handle_out("gameover", %{game: game}, socket) do
    win? =
      if winner = Game.winner(game) do
        winner.user.id === socket.assigns.user_id
      else
        false
      end

    push(socket, "gameover", %{game: game, win?: win?})
    {:noreply, socket}
  end
end
