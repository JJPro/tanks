defmodule Tanks.Gaming.Components.Player do
  alias __MODULE__

  defstruct [:user, :host?, :ready?, :sprite]

  @type t :: %Player{
          user: %Tanks.Accounts.User{},
          host?: boolean(),
          ready?: boolean(),
          sprite: String.t()
        }
end
