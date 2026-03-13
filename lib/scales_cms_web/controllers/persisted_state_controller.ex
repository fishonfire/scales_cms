defmodule ScalesCmsWeb.PersistedStateController do
  @moduledoc """
  Controller for persisting UI state to the session.

  LiveView cannot directly write to the Plug session because it runs
  over WebSockets. This controller provides an HTTP endpoint that
  allows the client to persist UI state changes to the session.
  """

  use ScalesCmsWeb, :controller

  @enabled_sidebar Application.compile_env(:scales_cms, :enabled_sidebar, true)

  @custom_states Application.compile_env(:scales_cms, :custom_persistence_states, [])

  @allowed_states (if(@enabled_sidebar, do: [:sidebar_open], else: []) ++
                     @custom_states)
                  |> Enum.map(&Atom.to_string/1)

  @doc """
  Updates a persisted UI state in the Plug session.

  Expects JSON:

      { "name": "sidebar_open", "value": true }
  """
  def update(conn, %{"name" => name, "value" => value})
      when is_binary(name) and is_boolean(value) and name in @allowed_states do
    conn
    |> put_session(name, value)
    |> send_resp(:no_content, "")
  end

  def update(conn, %{"name" => name, "value" => "true"}) do
    update(conn, %{"name" => name, "value" => true})
  end

  def update(conn, %{"name" => name, "value" => "false"}) do
    update(conn, %{"name" => name, "value" => false})
  end

  def update(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      error: "Invalid request. Expected {\"name\": string, \"value\": boolean}"
    })
  end
end
