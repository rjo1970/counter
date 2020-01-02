defmodule Counter.CrdtModel do
  @moduledoc """
  A Model to drive the Counter.Api that uses a conflict-free, replicated
  data type to allow in all cases merging existing data between nodes.

  This forms an eventually-consistent data model, allowing multiple nodes
  to participate as a single counter without negotiating leader/follower
  policies.  In CAP terms, this is an AP system, remaining Available and
  Partition-tolerant.  The risk is that increments to a node could be
  lost if it fails to share its data before being taken down.

  The name can be defined as a Keyword argument `counter_node_name` or
  default as the result of evaluating `Node.self()`
  """

  @spec init(keyword) :: {Atom, %{Atom => %{count: 0, never_merged: true, version: 0}}}
  def init(args) do
    {node_name(args), %{node_name(args) => %{count: 0, never_merged: true, version: 0}}}
  end

  @spec node_name(keyword) :: Atom
  def node_name(args \\ []) do
    {name, _} = Keyword.pop(args, :counter_node_name, Node.self())
    name
  end

  def inc({node_name, model}, value) when value >= 0 do
    # Increment only your own node in the model.
    node = Map.get(model, node_name)
    model = Map.put(model, node_name, %{node | count: node.count + value})
    {node_name, model}
  end

  def read({_node_name, model}) do
    # To get the sum of the counter, take the counts of all nodes, and sum them.
    Map.values(model)
    |> Enum.map(fn node -> node.count end)
    |> Enum.sum()
  end

  defp current_version(keys, model_a, model_b) do
    keys
    |> Enum.map(fn k ->
      a_version = get_in(model_a, [k, :version]) || 0
      b_version = get_in(model_b, [k, :version]) || 0
      max(a_version, b_version)
    end)
    |> Enum.max()
  end

  defp model_record(model, key, current_version) do
    new_entry = %{count: 0, version: current_version, never_merged: true}
    entry = Map.get(model, key, new_entry)

    if entry.version != current_version do
      new_entry
    else
      entry
    end
  end

  def merge({node_name, model_a}, model_b) do
    keys =
      (Map.keys(model_a) ++ Map.keys(model_b))
      |> Enum.uniq()

    version = current_version(keys, model_a, model_b)

    merged_model =
      keys
      |> Enum.map(fn k ->
        a = model_record(model_a, k, version)
        b = model_record(model_b, k, version)
        {k, a, b}
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

          # Switch the flag off so we know we have now merged
          # and set the count
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

  def reset({node_name, model}, value) do
    {node_name,
     %{
       node_name => %{
         count: value,
         never_merged: true,
         version: get_in(model, [node_name, :version]) + 1
       }
     }}
  end
end
