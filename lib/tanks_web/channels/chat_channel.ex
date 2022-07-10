defmodule TanksWeb.ChatChannel do
  use TanksWeb, :channel
  alias Tanks.Store.ChatStore
  alias Tanks.Accounts

  @impl true
  def join("chat:" <> room, _payload, socket) do
    history = ChatStore.get(room)
    {:ok, %{history: history}, socket}
  end

  @impl true
  def handle_in("send", %{"message" => message}, socket) do
    if socket.assigns[:user_id] do
      user = Accounts.get_user!(socket.assigns.user_id)
      broadcast(socket, "message", %{sender: user.name, message: message})
      "chat:" <> room = socket.topic
      ChatStore.put(room, %{sender: user.name, message: message})
    end

    {:noreply, socket}
  end

  def handle_in("typing_prompt", _, socket) do
    if socket.assigns[:user_id] do
      user = Accounts.get_user!(socket.assigns.user_id)
      broadcast_from!(socket, "typing_prompt", %{name: user.name})
    end

    {:noreply, socket}
  end
end
