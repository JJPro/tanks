defmodule Tanks.Gaming.Artifacts.Tank do
  alias __MODULE__

  @width 2
  @height 2

  @enforce_keys [:orientation, :player]
  @derive Jason.Encoder
  defstruct x: 0,
            y: 0,
            width: @width,
            height: @height,
            hp: 4,
            orientation: nil,
            player: nil

  @type t :: %Tank{
          orientation: :up | :down | :left | :right,
          player: Tanks.Gaming.Artifacts.Player.t(),
          x: integer(),
          y: integer(),
          width: unquote(@width),
          height: unquote(@height),
          hp: 1..4
        }
end
