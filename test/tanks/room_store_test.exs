defmodule Tanks.RoomStoreTest do
  use Tanks.DataCase
  use ExUnit.Case, async: true
  alias Tanks.Store.RoomStore
  alias Tanks.Gaming.Room
  import Tanks.AccountsFixtures
  @name "hi"

  setup do
    users =
      for _ <- 1..5 do
        user_fixture()
      end

    host = List.first(users)
    room = Room.new(@name, host)
    # start_supervised!(RoomStore)

    on_exit(fn ->
      # Clean up RoomStore after each test
      rooms = RoomStore.get_all()
      Enum.each(rooms, fn {name, _room} ->
        RoomStore.delete(name)
      end)
    end)

    %{room: room}
  end

  test "stores room by key", %{room: room} do
    assert RoomStore.get(@name) == nil
    RoomStore.put(@name, room)
    assert RoomStore.get(@name) == room
  end

  test "deletes room by key", %{room: room} do
    assert RoomStore.get(@name) == nil
    RoomStore.put(@name, room)
    RoomStore.put("there", room)
    assert length(RoomStore.get_all()) == 2
    RoomStore.delete(@name)
    assert length(RoomStore.get_all()) == 1
    assert RoomStore.get(@name) == nil
    RoomStore.delete("there")
    assert length(RoomStore.get_all()) == 0
  end

  test "is permanent worker" do
    assert Supervisor.child_spec(RoomStore, []).restart == :permanent
  end

end
