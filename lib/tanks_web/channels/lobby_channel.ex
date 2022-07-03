defmodule TanksWeb.LobbyChannel do
  @moduledoc """
  ## LobbyChannel

  This channel handles live communications to the lobby topic.

  ## Topic

  "lobby"

  ## Events

  The channel is responsible for handling events emitted from its clients,
  and for forwarding broadcasting messages, initiated from various places of the app, to its clients.

  ### Incomming Events From Its Clients

  | event | payload |
  | ----- | ------- |

  ### Forwarded Broadcasts To Clients (To Be Handled in Clients)

  Broadcasted events are events emitted from other places of the application,
  and needs to be handled by the client side (JS).
  This module simply forwards those broadcasting messages to user clients,
  and the clients (JS) needs to handle them.

  | event       | payload       |
  | ----------- | ------------- |
  | room_change | %{room: room} |
  | close_room  | %{room: room} |

  """
  use TanksWeb, :channel

  @impl true
  def join("lobby", _payload, socket) do
    rooms =
      Tanks.Store.RoomStore.get_all()
      |> Enum.map(fn {name, room} ->
        %{name: name, status: Tanks.Gaming.Room.get_status(room)}
      end)

    {:ok, %{rooms: rooms}, socket}
  end
end
