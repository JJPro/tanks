defmodule Tanks.Gaming.Components.Player do
  alias __MODULE__

  defstruct [:user, :host?, :ready?, :sprite]

  @type t :: %Player{
          # TODO: update user type
          # user: %User{},
          host?: boolean(),
          ready?: boolean(),
          sprite: String.t()
        }
end
