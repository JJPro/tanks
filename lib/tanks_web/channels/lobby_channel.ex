defmodule TanksWeb.LobbyChannel do
  @moduledoc """
  ## LobbyChannel

  This channel handles live communications to the lobby topic.

  ## Topic

  "lobby"

  ## Events

  The channel is responsible for handling events emitted from its clients,
  and for forwarding broadcasting messages, initiated from various places of the app, to its clients.

  ### Handle Incomming Events From Its Clients

  | event       | payload      |
  | ----------- | ------------ |
  | search      | %{term}      |
  | create_room | %{room_name} |
  | join        | %{room_name} |

  ### Forwarded Broadcasts To Clients (To Be Handled in Clients)

  Broadcasted events are events emitted from other places of the application,
  and needs to be handled by the client side (JS).
  This module simply forwards those broadcasting messages to user clients,
  and the clients (JS) needs to handle them.

  | event       | payload                  |
  | ----------- | ------------------------ |
  | new_room    | %{room: Room.lobby_view} |
  | room_change | %{room: Room.lobby_view} |
  | close_room  | %{room: Room.lobby_view} |

  ### Outgoing Broadcasts to Other Topics

  | stage       | event       | pubsub topics         | payload                           |
  | ----------- | ----------- | --------------------- | --------------------------------- |
  | create room | new_room    | lobby                 | %{room: Room.lobby_view}          |
  | player join | room_change | lobby, room:room_name | %{room: Room.lobby_view}, %{room} |
  """
  use TanksWeb, :channel
  alias Tanks.Store.RoomStore
  alias Tanks.Gaming.Room

  @impl true
  def join("lobby", _payload, socket) do
    rooms =
      RoomStore.get_all()
      |> Enum.map(fn {_name, room} ->
        Tanks.Gaming.Room.lobby_view(room)
      end)

    {:ok, %{rooms: rooms}, socket}
  end

  @impl true
  def handle_in("search", %{"term" => term}, socket) do
    if room = RoomStore.get(term) do
      {:reply, {:ok, Room.lobby_view(room)}, socket}
    else
      {:reply, {:error, %{reason: "not found"}}, socket}
    end
  end

  @impl true
  def handle_in("create_room", %{"room_name" => room_name}, socket) do
    case RoomStore.get(room_name) do
      %Room{} ->
        {:reply, {:error, %{reason: "room exists"}}, socket}

      nil ->
        user = Tanks.Accounts.get_user!(socket.assigns.user_id)
        room = Room.new(room_name, user)
        RoomStore.put(room_name, room)
        broadcast!(socket, "new_room", %{room: Room.lobby_view(room)})
        {:reply, :ok, socket}
    end
  end

  @impl true
  def handle_in("join", %{"room_name" => room_name}, socket) do
    case RoomStore.get(room_name) do
      %Room{} = room ->
        case Room.add_player(room, Tanks.Accounts.get_user!(socket.assigns.user_id)) do
          {:ok, room} ->
            :ok = RoomStore.put(room_name, room)
            TanksWeb.Endpoint.broadcast("room:" <> room_name, "room_change", %{room: room})

            if Room.get_status(room) == :full do
              broadcast!(socket, "room_change", %{room: Room.lobby_view(room)})
            end

            {:reply, :ok, socket}

          {:error, reason} ->
            {:reply, {:error, %{reason: reason}}, socket}
        end

      nil ->
        {:reply, {:error, %{reason: "not found"}}, socket}
    end
  end
end
