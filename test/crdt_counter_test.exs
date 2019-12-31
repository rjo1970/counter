defmodule Counter.CrdtModelTest do
  use ExUnit.Case

  test "Knows its default node name when provided no arguments" do
    expected = Node.self()
    result = Counter.CrdtModel.node_name([])
    assert result == expected
  end

  test "Can read the :counter_node_name key when provided" do
    result = Counter.CrdtModel.node_name(counter_node_name: :expected)
    assert result == :expected
  end

  test "Initial state has the {node_name, model} model has node as a key, and maps to a count" do
    {node, model} = Counter.CrdtModel.init([])
    assert get_in(model, [node, :count]) == 0
  end

  test "Incrementing the state works" do
    state = Counter.CrdtModel.init(counter_node_name: :node1)
    result = Counter.CrdtModel.inc(state, 42)
    assert {:node1, %{node1: %{count: 42}}} = result
  end

  test "Reading the state works" do
    result =
      Counter.CrdtModel.init(counter_node_name: :node1)
      |> Counter.CrdtModel.inc(42)
      |> Counter.CrdtModel.read()

    assert result == 42
  end

  test "Merging two different nodes requires the full local state and the remote model" do
    state1 =
      Counter.CrdtModel.init(counter_node_name: :node1)
      |> Counter.CrdtModel.inc(20)

    {_node2_name, model2} =
      Counter.CrdtModel.init(counter_node_name: :node2)
      |> Counter.CrdtModel.inc(22)

    result = Counter.CrdtModel.merge(state1, model2)
    assert {:node1, %{node1: %{count: 20}, node2: %{count: 22}}} = result
    assert Counter.CrdtModel.read(result) == 42
  end
end
