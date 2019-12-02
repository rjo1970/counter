defmodule Counter.Application do
  use Application

  @moduledoc """
  This is the top of the world.  It lists the child processes to start.
  In this case, a Counter.Worker should be started, and be supervised
  by the Counter.Supervisor process.
  """

  def start(_type, args) do
    children = [
      # Starts a worker by calling: Counter.Worker.start_link(arg)
      {Counter.Worker, args}
    ]

    # The one_for_one strategy makes sure that if the Counter.Worker crashes,
    # it will be immediately restarted by the Counter.Supervisor process.
    # The name Counter.Supervisor is just a reference to find the related
    # supervisor's process ID.  It is not a unit of code.
    opts = [strategy: :one_for_one, name: Counter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
