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

  test "Initial state has the node as a key, and maps to a count" do
    node = Node.self()
    result = Counter.CrdtModel.init([])
    assert get_in(result, [node, :count]) == 0
  end
end
