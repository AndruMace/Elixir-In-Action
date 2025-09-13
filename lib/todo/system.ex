defmodule Todo.System do
  # TODO: revisit chapter 11, benchmark, and try to make some of the suggested changes to improve benchmark results

  def start_link do
    Supervisor.start_link(
      [
        # Todo.Metrics,
        Todo.ProcessRegistry,
        Todo.Database,
        Todo.Cache,
        Todo.Web
      ],
      strategy: :one_for_one
    )
  end
end
