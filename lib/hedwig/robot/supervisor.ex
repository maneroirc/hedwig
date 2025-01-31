defmodule Hedwig.Robot.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, [], opts)
  end

  def config(robot, otp_app, opts) do
    if robot_config = Application.get_env(otp_app, robot) do
      robot_config
      |> Keyword.put(:otp_app, otp_app)
      |> Keyword.put(:robot, robot)
      |> Keyword.merge(opts)
    else
      raise ArgumentError,
            "configuration for #{inspect(robot)} not specified in #{inspect(otp_app)} environment"
    end
  end

  def parse_config(robot, opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    robot_config = Application.get_env(otp_app, robot, [])
    adapter = opts[:adapter] || robot_config[:adapter]

    if !adapter do
      raise ArgumentError,
            "missing `:adapter` configuration for " <>
              "#{inspect(otp_app)}, #{inspect(robot)}"
    end

    if !Code.ensure_loaded?(adapter) do
      raise ArgumentError,
            "adapter #{inspect(adapter)} was not compiled, " <>
              "ensure it is correct and it is included as a " <>
              "project dependency."
    end

    {otp_app, adapter, robot_config}
  end

  def init(_) do
    children = [
      Hedwig.Robot,
      [],
      restart: :transient
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
