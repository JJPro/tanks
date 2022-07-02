defmodule Tanks.Gaming.Artifacts.Steel do
  alias __MODULE__

  @width 1
  @height 1

  @derive Jason.Encoder
  defstruct x: 0, y: 0, width: @width, height: @height

  @type t :: %Steel{
          x: integer(),
          y: integer(),
          width: unquote(@width),
          height: unquote(@height)
        }
end
