defmodule ScalesCmsWeb.SidebarController do
  @moduledoc """
  Controller for persisting sidebar UI state to the session.

  This controller provides a simple endpoint for LiveView to persist
  sidebar open/closed state. Since LiveView cannot directly write to
  the session (it runs over WebSocket), we need this HTTP endpoint
  to handle session updates.

  ## Endpoint

  `POST /ui/sidebar` - Updates the sidebar state in the session.

  ## Request Body (JSON)

  ```json
  {
    "open": true | false
  }
  ```

  ## Response

  - `204 No Content` on success
  - `400 Bad Request` if the request body is invalid
  """

  use ScalesCmsWeb, :controller

  alias ScalesCmsWeb.Hooks.SidebarState

  @doc """
  Updates the sidebar state in the session.

  Expects a JSON body with `{"open": boolean}`.
  """
  def update(conn, %{"open" => open}) when is_boolean(open) do
    conn
    |> put_session(SidebarState.session_key(), open)
    |> send_resp(:no_content, "")
  end

  def update(conn, %{"open" => "true"}) do
    update(conn, %{"open" => true})
  end

  def update(conn, %{"open" => "false"}) do
    update(conn, %{"open" => false})
  end

  def update(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Invalid request. Expected {\"open\": boolean}"})
  end
end
