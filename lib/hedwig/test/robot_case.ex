defmodule Hedwig.RobotCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  require Logger

  @robot Hedwig.TestRobot
  @default_responders [{Hedwig.Responders.Help, []}, {TestResponder, []}]

  using do
    quote do
      import unquote(__MODULE__)

      @robot Hedwig.TestRobot
    end
  end

  setup tags do
    if tags[:start_robot] do
      robot = Map.get(tags, :robot, @robot)
      name = Map.get(tags, :name, "hedwig")
      responders = Map.get(tags, :responders, @default_responders)

      Logger.info("Hedwig.RobotCase: Starting robot with name: #{name} and responders: #{inspect(responders)}")

      # Ensure clean state before starting
      :global.unregister_name(name)

      config = [name: name, aka: "/", responders: responders]

      Application.put_env(:hedwig, robot, config)
      {:ok, pid} = Hedwig.start_robot(robot, config)
      Logger.info("Hedwig.RobotCase: Robot started successfully with PID: #{inspect(pid)}")
      adapter = update_robot_adapter(pid)

      on_exit(fn ->
        Hedwig.stop_robot(pid)
        :global.unregister_name(name)
        Logger.info("Hedwig.RobotCase: Robot stopped and name unregistered: #{name}")
      end)

      msg = %Hedwig.Message{robot: pid, text: "", user: "testuser"}

      {:ok, %{robot: pid, adapter: adapter, msg: msg}}
    else
      Logger.info("Hedwig.RobotCase: Robot not started, tags: #{inspect(tags)}")
      {:ok, tags}
    end
  end

  def update_robot_adapter(robot) do
    test_process = self()
    adapter = :sys.get_state(robot).adapter
    :sys.replace_state(adapter, fn state -> %{state | test_pid: test_process} end)

    adapter
  end
end
