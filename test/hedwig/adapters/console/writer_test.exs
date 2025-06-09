defmodule Hedwig.Adapters.Console.WriterTest do
  use ExUnit.Case

  alias Hedwig.Adapters.Console.Writer

  test "puts/2 sends message to connection" do
    {:ok, pid} = Writer.start_link({self(), "hedwig"})
    msg = %Hedwig.Message{text: "hello"}
    Writer.puts(pid, msg)
    assert_receive {:reply, ^msg}
  end

  test "clear/1 sends clear command" do
    {:ok, pid} = Writer.start_link({self(), "hedwig"})
    Writer.clear(pid)
    assert_receive {:message, "clear"}
  end
end
