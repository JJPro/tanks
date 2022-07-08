defmodule Tanks.Gaming.Artifacts.Missile do
  alias __MODULE__

  @width 0.2
  @height 0.2
  @speed 0.4

  @derive [Jason.Encoder, Tanks.Gaming.SquareDimension]
  defstruct x: 0, y: 0, width: @width, height: @height, direction: nil, speed: @speed

  @type t :: %Missile{
          x: integer(),
          y: integer(),
          width: float(),
          height: float(),
          direction: :up | :down | :left | :right,
          speed: float()
        }
end
