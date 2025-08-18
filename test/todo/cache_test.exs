defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache, "bob")
    alice_pid = Todo.Cache.server_process(cache, "alice")

    assert bob_pid != alice_pid
    assert bob_pid == Todo.Cache.server_process(cache, "bob")
  end

  test "todo operations" do
    {:ok, cache} = Todo.Cache.start()

    alice = Todo.Cache.server_process(cache, "alice")
    Todo.Server.add_entry(alice, %{date: ~D[2025-08-16], title: "Dentist"})

    entries = Todo.Server.entries(alice, ~D[2025-08-16])

    assert [%{date: ~D[2025-08-16], title: "Dentist"}] = entries
  end
end
