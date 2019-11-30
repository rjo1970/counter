defmodule CounterTest do
  use ExUnit.Case

  test "it works" do
    Counter.inc()
    assert Counter.read() == 1
  end
end
