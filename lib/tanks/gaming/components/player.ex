defmodule Tanks.Gaming.Components.Player do
  alias __MODULE__

  defstruct [:name, :id, :owner?, :ready?, :sprite]

  @type t :: %Player{
          name: String.t(),
          id: number(),
          owner?: boolean(),
          ready?: boolean(),
          sprite: String.t()
        }
end
