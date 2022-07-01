defmodule Tanks.RoomTest do
  use Tanks.DataCase

  alias Tanks.Gaming.Room
  import Tanks.AccountsFixtures

  @name "room name"

  setup do
    users =
      for _ <- 1..5 do
        user_fixture()
      end

    host = List.first(users)
    room = Room.new(@name, host)

    %{room: room, users: users}
  end

  test "can create new room", %{room: room, users: users} do
    assert room.name == @name
    assert length(room.players) == 1
    assert List.first(room.players).user == List.first(users)
  end

  test "adds player to room", %{room: room, users: users} do
    user2 = Enum.at(users, 1)
    user3 = Enum.at(users, 2)

    {:ok, room} = Room.add_player(room, user2)
    {:ok, room} = Room.add_player(room, user3)
    assert 3 == length(room.players)
    assert Room.get_status(room) == :open

    user4 = Enum.at(users, 3)
    {:ok, room} = Room.add_player(room, user4)
    assert Room.get_status(room) == :full

    user5 = Enum.at(users, 4)
    assert {:error, "room is full"} == Room.add_player(room, user5)
  end

  test "removes player from room", %{room: room, users: users} do
    room =
      Enum.reduce(0..3, room, fn index, room ->
        {:ok, room} = Room.add_player(room, Enum.at(users, index))
        room
      end)

    assert :full == Room.get_status(room)
    assert {:ok, room} = Room.remove_player(room, Enum.at(users, 0))
    assert {:ok, room} = Room.remove_player(room, Enum.at(users, 1))
    assert {:ok, room} = Room.remove_player(room, Enum.at(users, 3))
    assert {:empty_room, nil} = Room.remove_player(room, Enum.at(users, 2))
  end

  test "player_toggle_ready/2", %{room: room, users: users} do
    user2 = Enum.at(users, 1)
    user3 = Enum.at(users, 2)
    {:ok, room} = Room.add_player(room, user2)
    {:ok, room} = Room.add_player(room, user3)
    room = Room.player_toggle_ready(room, user2)

    assert Enum.all?(room.players, fn player ->
             if player.user == user2, do: player.ready?, else: not player.ready?
           end)
  end

  test "host/1 gives the correct host", %{room: room, users: users} do
    room =
      Enum.reduce(0..3, room, fn index, room ->
        {:ok, room} = Room.add_player(room, Enum.at(users, index))
        room
      end)

    assert Room.host(room).user == Enum.at(users, 0)
    assert {:ok, room} = Room.remove_player(room, Enum.at(users, 0))
    assert Room.host(room).user == Enum.at(users, 1)
  end
end
