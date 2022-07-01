defmodule Tanks.Gaming.Artifacts.Player do
  alias __MODULE__

  @enforce_keys [:user, :sprite]
  defstruct [user: nil, ready?: false, sprite: nil]

  @type t :: %Player{
          user: %Tanks.Accounts.User{},
          ready?: boolean(),
          sprite: String.t()
        }
end
