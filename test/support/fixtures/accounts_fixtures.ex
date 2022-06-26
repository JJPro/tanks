defmodule Tanks.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tanks.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "user@example.com",
        name: "some name"
      })
      |> Tanks.Accounts.register_user()

    user
  end
end
