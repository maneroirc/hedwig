defmodule Hedwig.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: Hedwig.Supervisor)
  end

  @impl true
  def init(:ok) do
    children = [
      {Hedwig.Robot.Supervisor, [name: Hedwig.Robot.Supervisor]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
