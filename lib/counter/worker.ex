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

  There is no knowlege of how a counter works, but we now need to
  synchronize state between different nodes.
  """
  use GenServer

  alias Counter.CrdtModel, as: Model

  # A 'tick' happens every 10 seconds to
  # distribute our state to peers.
  @tick_interval 10_000

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
    # We start the timer for a repeated tick event.
    schedule_tick()

    # This creates our initial state.  Any return value other than
    # `{:ok, initial_state}` will crash on startup.
    {:ok, Model.init(args)}
  end

  def schedule_tick() do
    # This will send a :tick info message to the GenServer after @tick_interval ms.
    Process.send_after(self(), :tick, @tick_interval)
  end

  @impl GenServer
  def handle_info(:tick, state) do
    # This sends our model to other nodes, who will accept and merge it.
    # It does not cause other nodes to send messages themselves.  This prevents
    # causing a message storm.
    Counter.Distributor.send_to_nodes(state)
    schedule_tick()
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:merge, model}, state) do
    {:noreply, Model.merge(state, model)}
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
  def handle_call({:reset, value}, _from, state) when is_integer(value) do
    # Resetting our state works if we are the only node.
    # In a multi-node cluster, our state will be returned to us on the next
    # tick of another system.

    # It is tempting to tell other systems to reset here, similar to the tick
    # info handler above.  In this case, it would cause a never-ending storm
    # of messages between nodes constantly resetting each other.

    # Instead, it should be handled by the API layer.
    {:reply, value, Model.reset(state, value)}
  end
end
