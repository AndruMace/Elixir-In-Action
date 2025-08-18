defmodule Todo.Server do
  use GenServer

  # client

  def start(list_name) do
    GenServer.start(Todo.Server, list_name)
  end

  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  # server

  @impl GenServer
  def init(list_name) do
    {:ok, {Todo.List.new(), list_name}}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {todo_list, list_name}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(list_name, new_list)
    {:noreply, {new_list, list_name}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {todo_list, list_name}) do
    this_todo = Todo.Database.get(list_name)
    {:reply, Todo.List.entries(this_todo, date), todo_list}
  end
end
