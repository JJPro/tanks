defmodule TanksWeb.GameChannelTest do
  use TanksWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      TanksWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(TanksWeb.GameChannel, "game:lobby")

    %{socket: socket}
  end
end
