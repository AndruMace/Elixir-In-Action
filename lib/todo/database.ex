defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  # client interface
  def start, do: GenServer.start(__MODULE__, nil, name: __MODULE__)
  def store(key, data), do: GenServer.cast(__MODULE__, {:store, key, data})
  def get(key), do: GenServer.call(__MODULE__, {:get, key})

  # server
  def init(_) do
    File.mkdir_p!(@db_folder)
    {:ok, nil}
  end

  def handle_cast({:store, key, data}, state) do
    key |> file_name() |> File.write!(:erlang.term_to_binary(data))
    {:noreply, state}
  end

  def handle_call({:get, key}, _, state) do
    data =
      case File.read(file_name(key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, state}
  end

  defp file_name(key), do: Path.join(@db_folder, to_string(key))
end
