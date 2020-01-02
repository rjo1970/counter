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
end
