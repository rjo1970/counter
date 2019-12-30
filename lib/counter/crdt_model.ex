defmodule Counter.CrdtModel do
  @spec init(keyword) :: {Atom, %{Atom => %{count: 0}}}
  def init(args) do
    {node_name(args), %{node_name(args) => %{count: 0}}}
  end

  @spec node_name(keyword) :: Atom
  def node_name(args \\ []) do
    {name, _} = Keyword.pop(args, :counter_node_name, Node.self())
    name
  end

  def inc({node_name, model}, value) when value >= 0 do
    node = Map.get(model, node_name)
    model = Map.put(model, node_name, %{node | count: node.count + value})
    {node_name, model}
  end

  def read({_node_name, model}) do
    Map.values(model)
    |> Enum.reduce(0, fn node, a ->
      a + node.count
    end)
  end

  def merge({node_name, model_a}, model_b) do
    keys = Map.keys(model_a) ++ Map.keys(model_b)

    merged_model =
      keys
      |> Enum.map(fn k ->
        {k, Map.get(model_a, k, %{count: 0}), Map.get(model_b, k, %{count: 0})}
      end)
      |> Enum.map(fn {k, a, b} ->
        if a.count > b.count do
          {k, a}
        else
          {k, b}
        end
      end)
      |> Map.new()

    {node_name, merged_model}
  end

  def reset({node_name, _model}, value) do
    # Careful, this isn't going to work "in the real world"
    # Even though we can use it to pass tests with a minor signature change in the worker
    # so we preserve our node name.
    init(counter_node_name: node_name)
    |> inc(value)
  end
end
