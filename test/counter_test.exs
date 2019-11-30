defmodule CounterTest do
  use ExUnit.Case

  test "It can read" do
    Counter.reset(0)
    assert Counter.read() == 0
  end

  test "It can increment" do
    Counter.reset(0)
    Counter.inc()
    assert Counter.read() == 1
  end

  test "It can reset" do
    Counter.inc()
    Counter.reset(0)
    assert Counter.read() == 0
  end
end
