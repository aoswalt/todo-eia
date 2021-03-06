defmodule Todo.Server do
  use GenServer

  def start(list_name) do
    GenServer.start(Todo.Server, list_name)
  end

  def init(list_name) do
    {:ok, {list_name, Todo.Database.get(list_name) || Todo.List.new()}}
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def update_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:update_entry, new_entry})
  end

  def delete_entry(todo_server, entry_id) do
    GenServer.cast(todo_server, {:delete_entry, entry_id})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  def handle_cast({:add_entry, new_entry}, {list_name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(list_name, new_state)
    {:noreply, {list_name, new_state}}
  end

  def handle_cast({:update_entry, new_entry}, {list_name, todo_list}) do
    {:noreply, {list_name, Todo.List.update_entry(todo_list, new_entry)}}
  end

  def handle_cast({:delete_entry, entry_id}, {list_name, todo_list}) do
    {:noreply, {list_name, Todo.List.delete_entry(todo_list, entry_id)}}
  end

  def handle_call({:entries, date}, _, {list_name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {list_name, todo_list}}
  end
end
