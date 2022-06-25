defmodule Tanks.Gaming.Components.Steel do
  alias __MODULE__

  @width 1
  @height 1

  defstruct x: 0, y: 0, width: @width, height: @height

  @type t :: %Steel{
          x: integer(),
          y: integer(),
          width: unquote(@width),
          height: unquote(@height)
        }
end
