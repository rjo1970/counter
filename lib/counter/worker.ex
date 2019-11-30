defmodule Counter.Worker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{count: 0}}
  end

  def handle_cast(:inc, state) do
    state = %{state | count: state.count + 1}
    {:noreply, state}
  end

  def handle_call(:read, _from, state) do
    {:reply, state.count, state}
  end

  def handle_call({:reset, value}, _from, state) when is_integer(value) do
    state = %{state | count: value}
    {:reply, value, state}
  end
end
