defmodule Tanks.Store.ChatStore do
  use Agent, restart: :permanent

  @type packet :: {sender :: String.t(), msg :: String.t()}

  @spec start_link(list()) :: Agent.on_start()
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @spec put(String.t(), packet()) :: no_return()
  def put(room, packet) do
    Agent.update(__MODULE__, fn state ->
      Map.update(state, room, [packet], fn packets ->
        packets =
          if length(packets) >= 100 do
            List.delete_at(packets, 99)
          else
            packets
          end

        [packet | packets]
      end)
    end)
  end

  @spec get(String.t()) :: [packet()]
  def get(room) do
    Agent.get(__MODULE__, &(Map.get(&1, room, []) |> Enum.reverse()))
  end

  @spec delete(String.t()) :: no_return()
  def delete(room) do
    Agent.update(__MODULE__, &Map.delete(&1, room))
  end
end
