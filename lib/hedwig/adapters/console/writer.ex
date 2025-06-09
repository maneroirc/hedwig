defmodule Hedwig.Adapters.Console.Writer do
  @moduledoc """
  Console writer for the console adapter.
  """

  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, {self(), name})
  end

  def puts(pid, msg) do
    GenServer.cast(pid, {:puts, msg})
  end

  def clear(pid) do
    GenServer.cast(pid, :clear)
  end

  def init({owner, name}) do
    {:ok, %{owner: owner, name: name}}
  end

  def handle_cast({:puts, msg}, state) do
    send(state.owner, {:reply, msg})
    {:noreply, state}
  end

  def handle_cast(:clear, state) do
    send(state.owner, {:message, "clear"})
    {:noreply, state}
  end
end
