defmodule TanksWeb.UserSocket do
  use Phoenix.Socket

  # A Socket handler
  #
  # It's possible to control the websocket connection and
  # assign values that can be accessed by your channel topics.

  ## Channels

  channel "room:*", TanksWeb.RoomChannel
  channel "lobby", TanksWeb.LobbyChannel
  channel "game:*", TanksWeb.GameChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do

    case Phoenix.Token.verify(socket, token_salt(), token, max_age: 1209600) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}
      {:error, _} ->
        {:ok, socket}
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Elixir.TanksWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(_socket), do: nil

  ## User Token Plug

  def put_user_token(conn, _opts) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, token_salt(), current_user.id)
      Plug.Conn.assign(conn, :user_token, token)
    else
      conn
    end
  end

  defp token_salt do
    "user socket"
  end
end
