defmodule Counter.Api do
  def inc() do
    GenServer.cast(Counter.Worker, :inc)
  end

  def read() do
    GenServer.call(Counter.Worker, :read)
  end

  def reset(value) when is_integer(value) do
    GenServer.call(Counter.Worker, {:reset, value})
  end
end
