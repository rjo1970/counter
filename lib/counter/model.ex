defmodule Counter.Model do
  @moduledoc """
  The Counter.Model represents the business logic.
  Anything that needs to "look inside" the model needs
  to happen in this file.

  It has these responsibilities:
   * defines the model structure,
   * initiates state,
   * updates state,
   * asks the state questions
  """

  # This says a %Counter.Model{} has a single field, count, defaulted to 0
  defstruct count: 0

  @type t :: %Counter.Model{count: integer}

  @spec init([any]) :: Counter.Model.t()
  def init(_args) do
    # This returns the initial value- a Counter.Model with defaulted fields.
    %__MODULE__{}
  end

  @spec inc(Counter.Model.t(), integer) :: Counter.Model.t()
  def inc(model, value) do
    # This creates a new model based on the previous model.count and value.
    %__MODULE__{model | count: model.count + value}
  end

  @spec read(Counter.Model.t()) :: integer
  def read(%Counter.Model{} = model) do
    # This method hides *how* the model calculates the count.
    # By having the logic here, we can change everything without having
    # to change every model.count reference out in the codebase.
    model.count
  end

  @spec reset(integer) :: Counter.Model.t()
  def reset(value) when is_integer(value) do
    # Just create a new model with the provided value.
    %__MODULE__{count: value}
  end
end
