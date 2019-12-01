defmodule Counter do
  defdelegate inc(value \\ 1), to: Counter.Api
  defdelegate read(), to: Counter.Api
  defdelegate reset(value \\ 0), to: Counter.Api
end
