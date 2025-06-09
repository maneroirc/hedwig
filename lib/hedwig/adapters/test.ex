defmodule Hedwig.Adapters.Test do
  @moduledoc false

  use Hedwig.Adapter

  require Logger

  def init({owner, opts}) do
    robot = opts[:robot] || Hedwig.TestRobot
    Logger.info("Initializing Hedwig.Adapters.Test with robot: #{inspect(robot)} and options: #{inspect(opts)}")
    Logger.debug("Owner process: #{inspect(owner)}")
    GenServer.cast(self(), :after_init)
    {:ok, %{robot_pid: owner, test_pid: owner, opts: opts, robot: robot}}
  end

  def handle_cast(:after_init, %{robot: robot, robot_pid: robot_pid} = state) do
    Logger.info("Handling :after_init for robot: #{inspect(robot)}")

    case Hedwig.Robot.handle_connect(robot_pid) do
      :ok -> Logger.debug("Robot connected successfully: #{inspect(robot)}")
      {:error, reason} -> Logger.error("Failed to connect robot: #{inspect(robot)}, reason: #{inspect(reason)}")
    end

    {:noreply, state}
  end

  def handle_cast({:send, msg}, %{test_pid: test_pid} = state) do
    Kernel.send(test_pid, {:message, %{text: msg.text, user: msg.user}})
    {:noreply, state}
  end

  def handle_cast({:reply, %{text: text, user: user} = _msg}, %{test_pid: test_pid} = state) do
    Kernel.send(test_pid, {:message, %{text: "#{user}: #{text}", user: user}})
    {:noreply, state}
  end

  def handle_cast({:emote, %{text: text, user: user} = _msg}, %{test_pid: test_pid} = state) do
    Kernel.send(test_pid, {:message, %{text: "* #{text}", user: user}})
    {:noreply, state}
  end

  def handle_info({:message, msg}, %{robot: robot, robot_pid: robot_pid} = state) do
    Logger.debug("Received message: #{inspect(msg)} for robot: #{inspect(robot)}")
    msg = %Hedwig.Message{robot: robot_pid, text: msg.text, user: msg.user}
    Hedwig.Robot.handle_in(robot_pid, msg)
    {:noreply, state}
  end

  def handle_info(msg, %{robot_pid: robot_pid} = state) do
    Hedwig.Robot.handle_in(robot_pid, msg)
    {:noreply, state}
  end
end
