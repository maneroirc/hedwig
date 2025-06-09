Code.ensure_compiled(Hedwig.Adapters.Test)

defmodule Hedwig.TestRobot do
  @moduledoc false

  use Hedwig.Robot, otp_app: :hedwig, adapter: Hedwig.Adapters.Test

  require Logger

  def handle_connect(%{name: name, responders: responders, aka: aka, responder_sup: sup} = state) do
    Logger.info("Hedwig.TestRobot: Handling connect with name: #{name}")
    # First try to unregister any existing name to ensure clean state
    case :global.unregister_name(name) do
      :ok -> Logger.info("Hedwig.TestRobot: Unregistered name #{name} successfully")
      _ -> Logger.warning("Hedwig.TestRobot: Name #{name} was not registered")
    end
    # Then register our name
    case :global.register_name(name, self()) do
      :yes -> Logger.info("Hedwig.TestRobot: Registered name #{name} successfully")
      _ -> Logger.error("Hedwig.TestRobot: Failed to register name #{name}")
    end
    
    # Manually install responders since the cast mechanism isn't working
    Logger.info("Hedwig.TestRobot: Manually installing responders: #{inspect(responders)}")
    for {module, opts} <- responders do
      child_spec = %{
        id: module,
        start: {Hedwig.Responder, :start_link, [module, {aka, name, opts, self()}]},
        type: :worker,
        restart: :transient,
        shutdown: 500
      }

      case DynamicSupervisor.start_child(sup, child_spec) do
        {:ok, pid} -> Logger.info("Hedwig.TestRobot: Started responder #{module} with PID #{inspect(pid)}")
        {:error, reason} -> Logger.error("Hedwig.TestRobot: Failed to start responder #{module}: #{inspect(reason)}")
      end
    end
    
    responder_children = Supervisor.which_children(sup)
    Logger.info("Hedwig.TestRobot: Responders after manual installation: #{inspect(responder_children)}")
    
    {:ok, state}
  end

  def handle_disconnect(:error, state), do: {:disconnect, :normal, state}

  def handle_disconnect(:reconnect, state), do: {:reconnect, state}

  def handle_disconnect({:reconnect, timer}, state), do: {:reconnect, timer, state}



  def handle_in(%Hedwig.Message{} = msg, %{responder_sup: sup} = state) do
    Logger.info("Hedwig.TestRobot: Received message: #{inspect(msg)}")
    responders = Supervisor.which_children(sup)
    Logger.info("Hedwig.TestRobot: Available responders: #{inspect(responders)}")
    {:dispatch, msg, state}
  end

  def handle_in({:ping, from}, state) do
    Kernel.send(from, :pong)
    {:noreply, state}
  end

  def handle_in(msg, state) do
    super(msg, state)
  end

  def terminate(reason, state) do
    Logger.error("Hedwig.TestRobot: Terminating with reason: #{inspect(reason)} and state: #{inspect(state)}")
    :ok
  end
end