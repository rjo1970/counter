defmodule Counter.Worker do
  @moduledoc """
  This is the GenServer for the Counter.

  The Application starts this module under a Supervisor.
  Arguments passed down from Application are sent to `start_link`,
  which then pass the args down to `init`.

  **Preserving State is its prime function!**
  It brokers messages sent from the API into method calls on the model.
  These messages are handled in its own process, sequentially.
  Since each message is handled one-at-a-time, there is no risk of
  data being half-baked or lost between contending processes.  This
  is the secret sauce of reliable, simple asyncronous programming!

  There is no knowlege of how a counter works inside this file.
  You could completely replace the Counter.Model implementation. As
  long as the method signatures remained the same, nothing needs to
  change except the alias below.
  """
  use GenServer

  alias Counter.Model

  def start_link(args) do
    # The name `start_link` means that this process will enter a death pact
    # with whatever process started it.  If either process dies, so does the
    # other.

    # This call returns {:ok, process_id} and starts the GenServer process.
    # It is named the same as the module name, so we don't have to keep or
    # try to find our "pid", later.
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl GenServer
  def init(args) do
    # This creates our initial state.  Any return value other than
    # `{:ok, initial_state}` will crash on startup.
    {:ok, Model.init(args)}
  end

  @impl GenServer
  def handle_cast({:inc, value}, state) do
    # Casts are asynchronus.  The message is placed on the process
    # queue and control immediately returns to the caller to continue.
    # Because of this, there can be no return value.  The next state is
    # created in the second element of the tuple.
    {:noreply, Model.inc(state, value)}
  end

  @impl GenServer
  def handle_call(:read, _from, state) do
    # Calls are synchronous.  The caller blocks until this message
    # is taken from the GenServer's process queue, executed, and
    # a result is returned.
    {:reply, Model.read(state), state}
  end

  @impl GenServer
  def handle_call({:reset, value}, _from, _state) when is_integer(value) do
    # The second argument lets you know "who is asking"- most of the time,
    # it doesn't matter and is ignored.

    # In this method, we don't even need the state, since we will replace
    # it with a new state based on the value.
    {:reply, value, Model.reset(value)}
  end
end
