defmodule Counter do
  defdelegate inc(), to: Counter.Api
  defdelegate read(), to: Counter.Api
  defdelegate reset(value), to: Counter.Api
end
