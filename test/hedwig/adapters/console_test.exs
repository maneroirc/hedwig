defmodule Hedwig.Adapters.ConsoleTest do
  use ExUnit.Case

  alias Hedwig.Adapters.Console

  test "init/1" do
    opts = %{name: "hedwig"}
    {:ok, state} = Console.init(opts)
    assert state.writer == nil
    assert state.opts == opts
  end

  test "handle_connect/1" do
    opts = %{name: "hedwig"}
    {:ok, state} = Console.init(opts)
    {:ok, new_state} = Console.handle_connect(state)
    assert new_state.writer != nil
  end

  test "handle_disconnect/2" do
    opts = %{name: "hedwig"}
    {:ok, state} = Console.init(opts)
    {:ok, new_state} = Console.handle_connect(state)
    {:ok, final_state} = Console.handle_disconnect(:normal, new_state)
    assert final_state == new_state
  end

  test "handle_in/2" do
    opts = %{name: "hedwig"}
    {:ok, state} = Console.init(opts)
    {:ok, new_state} = Console.handle_connect(state)
    msg = %Hedwig.Message{text: "hello"}
    {:reply, reply_msg, final_state} = Console.handle_in(msg, new_state)
    assert reply_msg.text == "hello"
    assert final_state == new_state
  end

  test "handle_out/2" do
    opts = %{name: "hedwig"}
    {:ok, state} = Console.init(opts)
    {:ok, new_state} = Console.handle_connect(state)
    msg = %Hedwig.Message{text: "hello"}
    {:ok, final_state} = Console.handle_out(msg, new_state)
    assert final_state == new_state
  end

  test "emote/2" do
    opts = %{name: "hedwig"}
    {:ok, state} = Console.init(opts)
    {:ok, new_state} = Console.handle_connect(state)
    msg = %Hedwig.Message{text: "hello"}
    {:ok, final_state} = Console.handle_out(msg, new_state)
    assert final_state == new_state
  end
end
