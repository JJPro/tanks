defmodule TanksWeb.RoomChannelTest do
  use TanksWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      TanksWeb.UserSocket
      |> socket("user_id", %{user_id: 1})
      |> subscribe_and_join(TanksWeb.RoomChannel, "room:lobby")

    %{socket: socket}
  end

end
