defmodule CounterTest do
  use ExUnit.Case

  test "It can read" do
    Counter.reset()
    assert Counter.read() == 0
  end

  test "It can increment" do
    Counter.reset()
    Counter.inc()
    assert Counter.read() == 1
  end

  test "It can reset" do
    0..500 |> Enum.each(fn _x -> Counter.inc() end)
    Counter.reset()
    assert Counter.read() == 0
  end

  test "It can reset to arbitrary values" do
    Counter.reset(123)
    assert Counter.read() == 123
  end
end
