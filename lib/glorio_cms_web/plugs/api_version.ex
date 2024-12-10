defmodule GlorioCmsWeb.Plugs.ApiVersion do
  @moduledoc false
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    api_version =
      conn
      |> get_req_header("api_version")
      |> List.first() || "1.0.0"

    assign(conn, :api_version, api_version)
  end
end
