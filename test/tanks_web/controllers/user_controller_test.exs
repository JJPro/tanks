defmodule TanksWeb.UserControllerTest do
  use TanksWeb.ConnCase

  import Tanks.AccountsFixtures

  @update_attrs %{email: "updated@example.com", name: "some updated name"}
  @invalid_attrs %{email: "invalid email", name: nil}

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn =
        conn
        |> log_user_in(user)
        |> get(Routes.user_path(conn, :edit, user))

      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn =
        conn
        |> log_user_in(user)
        |> put(Routes.user_path(conn, :update, user), user: @update_attrs)

      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        conn
        |> log_user_in(user)
        |> put(Routes.user_path(conn, :update, user), user: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
