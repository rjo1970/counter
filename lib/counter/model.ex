defmodule Counter.Model do
  defstruct count: 0

  @spec init([any]) :: Counter.Model.t()
  def init(_args) do
    %__MODULE__{}
  end

  @spec inc(Counter.Model.t()) :: Counter.Model.t()
  def inc(model) do
    %__MODULE__{model | count: model.count + 1}
  end

  def read(model) do
    model.count
  end

  @spec reset(any) :: Counter.Model.t()
  def reset(value) when is_integer(value) do
    %__MODULE__{count: value}
  end
end
