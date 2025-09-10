defmodule SimpleRegistry do
  use GenServer

  def start_link, do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def register(name) do
    GenServer.call(__MODULE__, {:register, name})
  end

  def whereis(name) do
    GenServer.call(__MODULE__, {:whereis, name})
  end

  @impl GenServer
  def handle_info({:EXIT, pid, reason}, state) do
    IO.puts("Deleting #{pid} for #{reason}")

    {
      :noreply,
      Map.reject(state, fn {_k, v} -> v == pid end)
    }
  end

  @impl GenServer
  def init(_) do
    IO.puts("Starting Simple Registry...")
    :ets.new(__MODULE__, [:named_table, :public, write_concurrency: true])
    Process.flag(:trap_exit, true)
    # {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:register, name}, _, state) do
    {
      :reply,
      :ok,
      Map.put(state, name, self())
    }
  end

  @impl GenServer
  def handle_call({:whereis, name}, _, state) do
    {
      :reply,
      Map.get(state, name),
      state
    }
  end
end
