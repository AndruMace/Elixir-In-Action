defmodule Todo.Database do
  @pool_size 3
  @db_folder "./persist"

  def start_link(_) do
    File.mkdir_p!(@db_folder)

    children = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp worker_spec(worker_id) do
    default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  # Choosing a worker makes a request to the database server process. There we
  # keep the knowledge about our workers, and return the pid of the corresponding
  # worker. Once this is done, the caller process will talk to the worker directly.
  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  @impl GenServer
  def init(_) do
    IO.puts("Starting database server...")
    File.mkdir_p!(@db_folder)
    {:ok, start_workers()}
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _, workers) do
    worker_key = :erlang.phash2(key, 3)
    {:reply, Map.get(workers, worker_key), workers}
  end

  defp start_workers() do
    for index <- 1..3, into: %{} do
      {:ok, pid} = Todo.DatabaseWorker.start_link(@db_folder)
      {index - 1, pid}
    end
  end
end
