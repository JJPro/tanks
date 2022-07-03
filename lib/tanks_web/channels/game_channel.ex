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
  | gameover  | -             |

  """
  use TanksWeb, :channel
  alias Tanks.Gaming.GameServer
  alias Tanks.Store.RoomStore

  @impl true
  def join("game:" <> room_name, _payload, socket) do
    with room = RoomStore.get(room_name),
         game when is_pid(game) <- room.game,
         true <- Process.alive?(game) do
      {:ok, assign(socket, :game, game)}
    else
      _ -> {:error, %{reason: "terminated"}}
    end
  end

  @impl true
  def handle_in("fire", _payload, socket) do
    GameServer.fire(
      socket.assigns.game,
      socket.assigns.user_id
    )

    {:noreply, socket}
  end

  @impl true
  def handle_in("move", %{"direction" => direction}, socket) do
    GameServer.move(
      socket.assigns.game,
      socket.assigns.user_id,
      String.to_atom(direction)
    )

    {:noreply, socket}
  end
end
