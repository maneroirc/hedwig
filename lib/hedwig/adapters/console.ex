defmodule Hedwig.Adapters.Console do
  @moduledoc """
  Console adapter for Hedwig.
  """

  use Hedwig.Adapter

  alias Hedwig.Adapters.Console.Writer

  def init(opts) do
    {:ok, %{writer: nil, opts: opts}}
  end

  def handle_connect(state) do
    {:ok, writer} = Writer.start_link({self(), state.opts.name})
    {:ok, %{state | writer: writer}}
  end

  def handle_disconnect(_reason, state) do
    {:ok, state}
  end

  def handle_in(%{text: text} = msg, state) do
    {:reply, %{msg | text: text}, state}
  end

  def handle_out(msg, state) do
    Writer.puts(state.writer, msg)
    {:ok, state}
  end
end
