defmodule Counter.Worker do
  use GenServer

  alias Counter.Model

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl GenServer
  def init(args) do
    {:ok, Model.init(args)}
  end

  @impl GenServer
  def handle_cast(:inc, state) do
    {:noreply, Model.inc(state)}
  end

  @impl GenServer
  def handle_call(:read, _from, state) do
    {:reply, Model.read(state), state}
  end

  @impl GenServer
  def handle_call({:reset, value}, _from, _state) when is_integer(value) do
    {:reply, value, Model.reset(value)}
  end
end
