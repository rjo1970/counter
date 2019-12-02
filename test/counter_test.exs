defmodule CounterTest do
  use ExUnit.Case

  # These tests exercise the entire stack, not just the
  # business logic of the counter.  In this limited case,
  # this is "good enough."  If the logic was in any way more
  # complex, I would have a test suite just for the model.

  setup context do
    # The Counter.Application is started and A SINGLE
    # GENSERVER IS USED ACROSS ALL TESTS!
    # Because of this coupling, it is critical to have
    # a means to reset state between tests.
    Counter.reset()

    context
  end

  test "It can read." do
    assert Counter.read() == 0
  end

  test "It can increment." do
    Counter.inc()
    assert Counter.read() == 1
  end

  test "It can reset." do
    1..5 |> Enum.each(fn _x -> Counter.inc() end)
    Counter.reset()
    assert Counter.read() == 0
  end

  test "It continues to increment after read." do
    1..5 |> Enum.each(fn _x -> Counter.inc() end)
    Counter.read()
    1..5 |> Enum.each(fn _x -> Counter.inc() end)
    assert Counter.read() == 10
  end

  test "It can reset to arbitrary values." do
    Counter.reset(123)
    assert Counter.read() == 123
  end

  test "It cannot be reset to George." do
    catch_error do
      Counter.reset("George")
    end
  end

  test "It can increment by steps." do
    Counter.inc(5)
    assert Counter.read() == 5
  end
end
