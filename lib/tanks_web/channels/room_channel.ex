defmodule TanksWeb.RoomChannel do
  @moduledoc """
  ## RoomChannel

  The Room Channel handles live communications from individual gaming rooms.

  ## Topics

  room:<name>

  ## Events

  This channel is responsible for handling events emitted from the clients,
  and for passing broadcasted events, initiated from other places of the application, to clients.

  ### Incomming Events Emitted From Connectted Clients

  | event        | payload         |
  | ------------ | --------------- |
  | join         | -               |
  | leave        | -               |
  | kickout      | %{"player_uid"} |
  | toggle_ready | -               |
  | start        | -               |

  ### Broadcasts to Topics

  | stage               | event       | pubsub topics         | payload                                 |
  | ------------------- | ----------- | --------------------- | --------------------------------------- |
  | player join         | room_change | lobby, room:room_name | %{room: Room.lobby_view}, %{room: room} |
  | player leave        | room_change | lobby, room:room_name | %{room: Room.lobby_view}, %{room: room} |
  | player kicked out   | room_change | lobby, room:room_name | %{room: Room.lobby_view}, %{room: room} |
  | player toggle ready | room_change | room:room_name        | %{room: room}                           |
  | host starts game    | room_change | lobby, room:room_name | %{room: Room.lobby_view}, %{room: room} |
  | all players leave   | close_room  | lobby, room:room_name | %{room: Room.lobby_view}, %{room: room} |
  | kickout             | kickedout   | room:room_name        | %{room: room, player_uid}               |


  ### Passthrough Broadcasts From Other Modules (To Be Handled in Clients)

  Broadcasted events are events emitted from other places of the application,
  and needs to be handled by the client side (JS).
  This module simply forwards those broadcasting messages to user client,
  and the clients (JS) needs to handle them.

  #### Broadcasted From GameServer
  | event       | payload       |
  | ----------- | ------------- |
  | gamestart   | -             |
  | room_change | %{room: room} |

  You can learn more in Tanks.Gaming.GameServer.
  """
  use TanksWeb, :channel
  alias Tanks.Gaming.Room
  alias Tanks.Store.RoomStore
  alias Tanks.Accounts
  alias Tanks.Accounts.User

  ## User (Player and Observer) Actions

  @doc """
  Channel join:
  Both players and observers are able to join the channel
  """
  @impl true
  def join("room:" <> room_name, _payload, socket) do
    case RoomStore.get(room_name) do
      %Room{} = room ->
        %Tanks.Gaming.Artifacts.Player{} = host = Room.host(room)
        {:ok, %{room: room, user_id: socket.assigns.user_id, host_id: host.user.id}, socket}

      nil ->
        {:error, %{reason: "not found"}}
    end
  end

  ## Player Only Actions

  @impl true
  def handle_in("join", _payload, socket) do
    case lookup_and_update(socket, fn room, user ->
           case Room.add_player(room, user) do
             {:ok, updated_room} ->
               broadcast(socket, "room_change", %{room: updated_room})

               if Room.get_status(room) != Room.get_status(updated_room) do
                 TanksWeb.Endpoint.broadcast!("lobby", "room_change", %{
                   room: Room.lobby_view(updated_room)
                 })
               end

               {:ok, updated_room}

             {:error, _} = error ->
               error
           end
         end) do
      {:ok, _} -> {:noreply, socket}
      error -> {:reply, error, socket}
    end
  end

  @impl true
  def handle_in("leave", _payload, socket) do
    lookup_and_update(socket, fn room, user ->
      case Room.remove_player(room, user) do
        {:ok, updated_room} ->
          broadcast(socket, "room_change", %{room: updated_room})

          if Room.get_status(room) != Room.get_status(updated_room) do
            TanksWeb.Endpoint.broadcast!("lobby", "room_change", %{
              room: Room.lobby_view(updated_room)
            })
          end

          {:ok, updated_room}

        {:empty_room, nil} ->
          RoomStore.delete(room.name)
          broadcast(socket, "close_room", nil)
          TanksWeb.Endpoint.broadcast!("lobby", "close_room", %{room: Room.lobby_view(room)})

          # Return {:error, _} so that the room is not committed back to store
          {:error, "close room"}
      end
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_in("kickout", %{"player_uid" => player_uid}, socket) do
    lookup_and_update(socket, fn room, _host ->
      {:ok, updated_room} = Room.remove_player(room, Accounts.get_user!(player_uid))
      broadcast(socket, "kickedout", %{room: updated_room, player_uid: player_uid})

      if Room.get_status(room) != Room.get_status(updated_room) do
        TanksWeb.Endpoint.broadcast!("lobby", "room_change", %{
          room: Room.lobby_view(updated_room)
        })
      end

      {:ok, updated_room}
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_in("toggle_ready", _payload, socket) do
    lookup_and_update(socket, fn room, user ->
      {:ok, room} = Room.player_toggle_ready(room, user)
      broadcast(socket, "room_change", %{room: room})
      {:ok, room}
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_in("start", _payload, socket) do
    case lookup_and_update(socket, fn room, _user ->
           case Room.start_game(room) do
             {:ok, room} ->
               broadcast(socket, "room_change", %{room: room})

               TanksWeb.Endpoint.broadcast!("lobby", "room_change", %{room: Room.lobby_view(room)})

               {:ok, room}

             {:error, _msg} = error ->
               error
           end
         end) do
      {:ok, _} -> {:noreply, socket}
      error -> {:reply, error, socket}
    end
  end

  # Looks up a room and updates it with a callback.
  #
  # The callback takes the fetched room, and returns {:ok, updated_room} or {:error, message}
  # Only when the callback returns %{:ok, _} form, the updated room is saved to store.
  #
  # Returns:
  # {:error, :not_found}
  # | {:ok, room} | {:error, message}
  @typep callback_return :: {:ok, Room.t()} | {:error, String.t()}
  @spec lookup_and_update(Phoenix.Socket.t(), (Room.t(), %User{} -> callback_return())) ::
          callback_return() | {:error, :not_found}
  defp lookup_and_update(socket, callback) do
    "room:" <> room_name = socket.topic
    user = Accounts.get_user!(socket.assigns.user_id)

    case RoomStore.get(room_name) do
      %Room{} = room ->
        case callback.(room, user) do
          {:ok, room} = success ->
            RoomStore.put(room_name, room)
            success

          {:error, _msg} = error ->
            error
        end

      nil ->
        {:error, :not_found}
    end
  end
end
