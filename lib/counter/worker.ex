defmodule Counter.Worker do
  use GenServer

  alias Counter.Model

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, Model.init()}
  end

  def handle_cast(:inc, state) do
    {:noreply, Model.inc(state)}
  end

  def handle_call(:read, _from, state) do
    {:reply, Model.read(state), state}
  end

  def handle_call({:reset, value}, _from, _state) when is_integer(value) do
    {:reply, value, Model.reset(value)}
  end
end
