defmodule Counter.Api do
  def inc(value) do
    GenServer.cast(Counter.Worker, {:inc, value})
  end

  def read() do
    GenServer.call(Counter.Worker, :read)
  end

  def reset(value) when is_integer(value) do
    GenServer.call(Counter.Worker, {:reset, value})
  end
end
