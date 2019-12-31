defmodule Counter.CrdtModel do
  @spec init(keyword) :: {Atom, Map.t()}
  def init(args) do
    {node_name(args), %{node_name(args) => %{count: 0, never_merged: true}}}
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
    keys =
      (Map.keys(model_a) ++ Map.keys(model_b))
      |> Enum.uniq()

    merged_model =
      keys
      |> Enum.map(fn k ->
        {k, Map.get(model_a, k, %{count: 0}), Map.get(model_b, k, %{count: 0})}
      end)
      |> Enum.map(fn {k, a, b} ->
        never_merged = Map.get(a, :never_merged, false)

        if never_merged and k == node_name do
          # If we have just started running, but have racked up some increments,
          # we would lose them or the legacy count, whichever was less.
          #
          # Instead, if we have never merged before, we want to add new increments
          # to the returning legacy count.
          count = a.count + b.count

          a =
            Map.put(a, :never_merged, false)
            |> Map.put(:count, count)

          {k, a}
        else
          # In all other cases, we want to take the larger count
          if a.count > b.count do
            {k, a}
          else
            {k, b}
          end
        end
      end)
      |> Map.new()

    {node_name, merged_model}
  end

  def reset({node_name, _model}, value) do
    init(counter_node_name: node_name)
    |> inc(value)
  end
end
