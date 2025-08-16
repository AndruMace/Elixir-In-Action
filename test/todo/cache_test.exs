defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache, "bob")
    alice_pid = Todo.Cache.server_process(cache, "alice")

    assert bob_pid != alice_pid
    assert bob_pid == Todo.Cache.server_process(cache, "bob")
  end
end
