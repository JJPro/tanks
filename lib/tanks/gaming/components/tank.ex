defmodule Tanks.Gaming.Components.Tank do
  alias __MODULE__

  @enforce_keys [:orientation, :player]
  @width 2
  @height 2

  defstruct x: 0,
            y: 0,
            width: @width,
            height: @height,
            hp: 4,
            orientation: nil,
            player: nil
            # sprite: ""

  @type t :: %Tank{
          orientation: atom(),
          player: Tanks.Gaming.Components.Player.t(),
          # sprite: String.t(),
          x: integer(),
          y: integer(),
          width: unquote(@width),
          height: unquote(@height),
          hp: 1..4
        }
end
