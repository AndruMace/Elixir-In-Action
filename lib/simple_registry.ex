defmodule SimpleRegistry do
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def register(name) do
    Process.link(Process.whereis(__MODULE__))

    case :ets.insert_new(__MODULE__, {name, self()}) do
      true -> :ok
      false -> :error
    end
  end

  def whereis(name) do
    case :ets.lookup(__MODULE__, name) do
      [{^name, pid}] -> pid
      [] -> nil
    end
  end

  @impl GenServer
  def handle_info({:EXIT, pid, reason}, state) do
    IO.puts("Deleting #{pid} for #{reason}")
    :ets.match_delete(__MODULE__, {:_, pid})

    {
      :noreply,
      state
    }
  end

  @impl GenServer
  def init(_) do
    IO.puts("Starting Simple Registry...")
    Process.flag(:trap_exit, true)
    :ets.new(__MODULE__, [:named_table, :public, write_concurrency: true])
    {:ok, nil}
  end
end
