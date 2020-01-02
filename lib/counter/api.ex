defmodule Counter.Api do
  @moduledoc """
  This is the calling API into the Worker.
  It knows about the Counter.Worker and its use of GenServer.
  It has no knowledge at all of model or its implementation.
  It hides the fact that we are using a GenServer.

  The Counter facade allows this to be changed or replaced without
  having to change calls throughout the codebase.
  """

  def inc(value) do
    GenServer.cast(Counter.Worker, {:inc, value})
  end

  def read() do
    GenServer.call(Counter.Worker, :read)
  end

  def reset(value) when is_integer(value) and value >= 0 do
    GenServer.call(Counter.Worker, {:reset, value})
  end
end
