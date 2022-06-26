defmodule TanksWeb.UserControllerTest do
  use TanksWeb.ConnCase

  import Tanks.AccountsFixtures

  @create_attrs %{email: "one@example.com", name: "some name"}
  @update_attrs %{email: "updated@example.com", name: "some updated name"}
  @invalid_attrs %{email: "invalid email", name: nil}

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "some updated email"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
