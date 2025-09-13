defmodule Todo.Web do
  defp plug_builder_call(conn, opts) do
    case match(conn, []) do
      %Plug.Conn{halted: true} = conn ->
        nil
        conn

      %Plug.Conn{} = conn ->
        case dispatch(conn, []) do
          %Plug.Conn{halted: true} = conn ->
            nil
            conn

          %Plug.Conn{} = conn ->
            conn

          other ->
            :erlang.error(
              RuntimeError.exception(
                <<"expected dispatch/2 to return a Plug.Conn, all plugs must receive a connection (conn) and return a connection",
                  ", got: ", Kernel.inspect(other)::binary>>
              ),
              :none,
              error_info: %{module: Exception}
            )
        end

      other ->
        :erlang.error(
          RuntimeError.exception(
            <<"expected match/2 to return a Plug.Conn, all plugs must receive a connection (conn) and return a connection",
              ", got: ", Kernel.inspect(other)::binary>>
          ),
          :none,
          error_info: %{module: Exception}
        )
    end
  end

  def match(conn, _opts) do
    do_match(conn, conn.method, Plug.Router.Utils.decode_path_info!(conn), conn.host)
  end

  def init(opts) do
    opts
  end

  defp do_match(conn, "POST", ["add_entry"], _) do
    nil
    nil
    params = %{}

    merge_params = fn
      %Plug.Conn.Unfetched{} -> params
      fetched -> :maps.merge(fetched, params)
    end

    conn = Map.update!(conn, :params, merge_params)
    conn = Map.update!(conn, :path_params, merge_params)

    Plug.Router.__put_route__(conn, "/add_entry", fn conn, opts ->
      _ = opts
      nil
    end)
  end

  def dispatch(%Plug.Conn{} = conn, opts) do
    {path, fun} = :maps.get(:plug_route, conn.private)

    try do
      :telemetry.span(
        [:plug, :router_dispatch],
        %{conn: conn, route: path, router: Todo.Web},
        fn ->
          conn = fun.(conn, opts)
          {conn, %{conn: conn, route: path, router: Todo.Web}}
        end
      )
    catch
      kind, reason -> Plug.Conn.WrapperError.reraise(conn, kind, reason, __STACKTRACE__)
    end
  end

  def child_spec(_arg) do
    Plug.Cowboy.child_spec(scheme: :http, options: [port: 5454], plug: Todo.Web)
  end

  def call(conn, opts) do
    plug_builder_call(conn, opts)
  end
end