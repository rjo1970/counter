defmodule Counter.Api do
  def inc() do
    GenServer.cast(Counter.Worker, :inc)
  end

  def read() do
    GenServer.call(Counter.Worker, :read)
  end
end
