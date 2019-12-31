defmodule Counter.Distributor do
  @moduledoc """
  Distribute messages to other member nodes.
  """

  @doc """
  Share your state with other nodes.  Does not update this node.
  """
  def send_to_nodes({_my_server_identity, model}) do
    Node.list()
    |> Enum.each(fn node ->
      GenServer.cast({Elixir.Counter.Worker, node}, {:merge, model})
    end)
  end

  @doc """
  Tell other nodes to reset their state.  The danger is that this is
  incomplete.  In-flight updates on other nodes could persist the data
  thorugh a reset.  An ideal solution would be to increment a version
  of our counter such that old versions are not considered and new ones
  start with zero.
  """
  def reset_nodes(value \\ 0) do
    Node.list()
    |> Enum.each(fn node ->
      GenServer.call({Elixir.Counter.Worker, node}, {:reset, value})
    end)
  end
end
