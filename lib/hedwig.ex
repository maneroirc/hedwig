defmodule Hedwig do
  @moduledoc """
  Hedwig Application

  ## Starting a robot

      {:ok, pid} = Hedwig.start_robot(MyApp.Robot, name: "alfred")

  ## Stopping a robot

      Hedwig.stop_client(pid)
  """

  use Application

  @doc false
  def start(_type, _args) do
    Hedwig.Supervisor.start_link()
  end

  @doc """
  Starts a robot with the given configuration.
  """
  def start_robot(robot, opts \\ []) do
    child_spec = %{
      id: robot,
      start: {robot, :start_link, [opts]},
      type: :worker,
      restart: if(Mix.env() == :test, do: :temporary, else: :permanent),
      shutdown: 5000,
      modules: [Hedwig.Robot]
    }

    DynamicSupervisor.start_child(Hedwig.Robot.Supervisor, child_spec)
  end

  @doc """
  Stops a robot with the given PID.
  """
  def stop_robot(pid) do
    DynamicSupervisor.terminate_child(Hedwig.Robot.Supervisor, pid)
  end

  @doc """
  List all robots.
  """
  def which_robots do
    DynamicSupervisor.which_children(Hedwig.Robot.Supervisor)
  end
end
