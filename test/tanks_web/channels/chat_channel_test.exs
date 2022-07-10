defmodule TanksWeb.ChatChannelTest do
  use TanksWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      TanksWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(TanksWeb.ChatChannel, "chat:lobby")

    %{socket: socket}
  end
end
