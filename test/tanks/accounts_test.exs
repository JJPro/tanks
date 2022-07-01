defmodule Tanks.AccountsTest do
  use Tanks.DataCase

  alias Tanks.Accounts

  describe "users" do
    alias Tanks.Accounts.User

    import Tanks.AccountsFixtures

    @invalid_attrs %{email: "invalid email", name: nil}

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "get_user_by_email/1 returns the user with given email" do
      user = user_fixture()
      assert Accounts.get_user_by_email(user.email) == user
    end

    test "register_user/1 with valid data creates a user" do
      valid_attrs = %{email: "test@example.com", name: "some name"}

      assert {:ok, %User{} = user} = Accounts.register_user(valid_attrs)
      assert user.email == "test@example.com"
      assert user.name == "some name"
    end

    test "register_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.register_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{email: "updated@example.com", name: "some updated name"}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.email == "updated@example.com"
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
