defmodule TodoServer do
  def start(entries \\ []) do
    todo_server = spawn(fn -> loop(TodoList.new(entries)) end)
    Process.register(todo_server, :todo_server)
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
        message -> process_message(todo_list, message)
      end

    loop(new_todo_list)
  end

  def add_entry(new_entry), do: send(:todo_server, {:add_entry, new_entry})

  def update_entry(entry, updater),
    do: send(:todo_server, {:update_entry, entry, updater})

  def delete_entry(entry), do: send(:todo_server, entry)

  def entries(date) do
    send(:todo_server, {:entries, date, self()})

    receive do
      {:response, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:entries, date, caller}) do
    send(caller, {:response, TodoList.entries(todo_list, date)})
    todo_list
  end

  defp process_message(todo_list, {:update_entry, entry, updater}) do
    TodoList.update_entry(todo_list, entry, updater)
  end

  defp process_message(todo_list, {:delete_entry, entry}) do
    TodoList.delete_entry(todo_list, entry)
  end
end

defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  @type t :: %__MODULE__{
          next_id: integer(),
          entries: %{integer() => map()}
        }

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      &add_entry(&2, &1)
    )
  end

  @spec add_entry(t(), map()) :: t()
  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)

    new_entries =
      Map.put(
        todo_list.entries,
        todo_list.next_id,
        entry
      )

    %TodoList{todo_list | entries: new_entries, next_id: todo_list.next_id + 1}
  end

  # @spec entries(t(), Date.t()) :: map()
  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(&(&1.date == date))
  end

  @spec update_entry(t(), integer(), fun()) :: t()
  def update_entry(todo_list, entry_id, updater) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    %TodoList{todo_list | entries: Map.delete(todo_list.entries, entry_id)}
  end

  def test_todo() do
    td = new()
    IO.inspect(td, label: "New todo list")

    new_td =
      td
      |> add_entry(%{date: ~D[2025-07-04], title: "Test Entry"})
      |> add_entry(%{date: ~D[2025-07-03], title: "Entry Test"})

    IO.inspect(new_td, label: "List with entries")
    IO.inspect(new_td |> entries(~D[2025-07-03]), label: "Fetch specific entry")
    del_td = new_td |> delete_entry(2)
    IO.inspect(del_td, label: "List with deleted entry")
  end
end

defmodule TodoList.CsvImporter do
  # %TodoList{
  #   entries: %{1=> %{date: date, title: "My todo"}},
  #   next_id: 2
  # }
  def import(path) do
    File.stream!(path)
    |> Stream.map(fn str -> String.trim(str) end)
    |> Stream.map(fn row ->
      [date_string, title] = String.split(row, ",")
      date = Date.from_iso8601!(date_string)
      %{date: date, title: title}
    end)
    |> TodoList.new()
  end
end

defimpl String.Chars, for: TodoList do
  def to_string(_) do
    "Todo"
  end
end

defimpl Collectable, for: TodoList do
  def into(og) do
    {og, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    TodoList.add_entry(todo_list, entry)
  end

  defp into_callback(todo_list, :done), do: todo_list
  defp into_callback(_todo_list, :halt), do: :ok
end
