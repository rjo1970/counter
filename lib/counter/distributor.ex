defmodule Counter.Distributor do
  def send_to_nodes({_my_server_identity, model}) do
    Node.list()
    |> Enum.each(fn node ->
      GenServer.cast({Elixir.Counter.Worker, node}, {:merge, model})
    end)
  end

  def reset_nodes(value) do
    Node.list()
    |> Enum.each(fn node ->
      GenServer.call({Elixir.Counter.Worker, node}, {:reset, value})
    end)
  end
end
