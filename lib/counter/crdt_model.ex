defmodule Counter.CrdtModel do
  @spec init(keyword) :: %{Atom => %{count: 0}}
  def init(args) do
    %{node_name(args) => %{count: 0}}
  end

  @spec node_name(keyword) :: Atom
  def node_name(args \\ []) do
    {name, _} = Keyword.pop(args, :counter_node_name, Node.self())
    name
  end
end
