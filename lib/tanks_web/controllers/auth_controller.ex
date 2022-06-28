defmodule TanksWeb.AuthController do
  use TanksWeb, :controller

  alias Tanks.Accounts
  alias Tanks.Accounts.User
  alias TanksWeb.UserAuth

  def register(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "register.html", changeset: changeset)
  end

  def register_handler(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "register.html", changeset: changeset)
    end
  end

  def login(conn, _params) do
    render(conn, "login.html", error_message: nil)
  end

  def login_handler(conn, %{"user" => user_params}) do
    %{"email" => email} = user_params

    if user = Accounts.get_user_by_email(email) do
      UserAuth.log_in_user(conn, user)
    else
      render(conn, "login.html", error_message: "Email not found")
    end
  end

  def logout_handler(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
