defmodule ScalesCms.ErrorHandler do
  @moduledoc """
  Error handler for JWT
  """
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    body = to_string(type)

    conn
    |> put_status(:unauthorized)
    |> Phoenix.Controller.put_view(ScalesCms.ErrorJSON)
    |> Phoenix.Controller.render("401.json", error: body)
    |> halt()
  end
end
