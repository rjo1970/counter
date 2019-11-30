defmodule Counter do
  defdelegate inc(), to: Counter.Api
  defdelegate read(), to: Counter.Api
end
