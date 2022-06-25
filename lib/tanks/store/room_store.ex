defmodule Tanks.Store.RoomStore do
  use Agent
  alias Tanks.Gaming.Room

  @spec start_link() :: Agent.on_start()
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Puts the `room` for the given `name`
  """
  @spec put(String.t(), Room.t()) :: :ok
  def put(name, room) do
    Agent.update(__MODULE__, &Map.put(&1, name, room))
  end

  @doc """
  Fetches the room with the given `name`
  """
  @spec get(String.t()) :: Room.t()
  def get(name) do
    Agent.get(__MODULE__, &Map.get(&1, name))
  end

  @doc """
  Deletes the room with given `name`
  """
  @spec delete(String.t()) :: Room.t() | nil
  def delete(name) do
    Agent.get_and_update(__MODULE__, &Map.pop(&1, name))
  end

  @doc """
  Fetch all rooms in the store
  """
  @spec get_all :: [{String.t(), Room.t()}]
  def get_all do
    Agent.get(__MODULE__, &Enum.into(&1, []))
  end
end
