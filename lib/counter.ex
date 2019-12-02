defmodule Counter do
  @moduledoc """
    This is the public interface into the counter.

    It is a layer of indirection between the API,
    which could change with just the alias reference below,
    and the myriad places in the code that use its functions.

    This just exposes the contract and passes down default values.
  """
  alias Counter.Api

  defdelegate inc(value \\ 1), to: Api
  defdelegate read(), to: Api
  defdelegate reset(value \\ 0), to: Api
end
