defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  # The following two lambda definitions are equivalent
  # &add_entry(&2, &1)
  # fn entry, todo_list_acc ->
  #   add_entry(todo_list_acc, entry)
  # end
  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      &add_entry(&2, &1)
    )
  end

  # IEX Usage
  # TodoList.new() |> TodoList.add_entry(%{date: ~D[2025-07-03], title: "I sure hope this works"}) |> TodoList.entries(~D[2025-07-02])
  @spec add_entry(TodoList, map()) :: TodoList
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

  @spec entries(TodoList, Date) :: TodoList
  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(&(&1.date == date))
  end

  @spec update_entry(TodoList, integer(), fun()) :: TodoList
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
