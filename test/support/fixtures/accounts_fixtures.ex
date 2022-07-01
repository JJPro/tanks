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
        email: "user" <> to_string(:rand.uniform) <> "@example.com",
        name: Enum.random(~w(Jason Jeff Bard Hellen Franck Kevin Dale Jessica))
      })
      |> Tanks.Accounts.register_user()

    user
  end
end
