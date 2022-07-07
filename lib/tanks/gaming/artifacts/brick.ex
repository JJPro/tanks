defmodule Tanks.Gaming.Artifacts.Brick do
  alias __MODULE__
  @width 1
  @height 1

  @derive [Jason.Encoder, Tanks.Gaming.SquareDimension]
  defstruct x: 0, y: 0, width: @width, height: @height

  @type t :: %Brick{
          x: integer(),
          y: integer(),
          width: unquote(@width),
          height: unquote(@height)
        }
end
