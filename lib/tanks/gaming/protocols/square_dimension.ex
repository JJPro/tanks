defprotocol Tanks.Gaming.SquareDimension do
  @typedoc """
  the object should have the following props:
        x, y, width
  """
  @type t :: term()

  @typedoc """
  The center point (x, y) and radius (r)
  """
  @type dimension :: {x :: number(), y :: number(), r :: number()}

  @spec dimension(t()) :: dimension()
  def dimension(obj)
end

defimpl Tanks.Gaming.SquareDimension, for: Any do
  def dimension(obj) do
    r = obj.width / 2
    {
      obj.x + r,
      obj.y + r,
      r
    }
  end
end
