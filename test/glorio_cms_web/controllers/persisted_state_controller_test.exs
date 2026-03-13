defmodule ScalesCmsWeb.PersistedStateControllerTest do
  use ScalesCmsWeb.ConnCase

  @custom_states Application.compile_env(:scales_cms, :custom_persistence_states, [])
  @custom_state @custom_states |> List.first() |> to_string()

  describe "POST /ui/state" do
    test "updates session with sidebar_open = true", %{conn: conn} do
      conn =
        conn
        |> log_in_user()
        |> post(~p"/ui/state", %{"name" => "sidebar_open", "value" => true})

      assert conn.status == 204
      assert get_session(conn, "sidebar_open") == true
    end

    test "updates session with sidebar_open = false", %{conn: conn} do
      conn =
        conn
        |> log_in_user()
        |> post(~p"/ui/state", %{"name" => "sidebar_open", "value" => false})

      assert conn.status == 204
      assert get_session(conn, "sidebar_open") == false
    end

    test "handles string 'true' value", %{conn: conn} do
      conn =
        conn
        |> log_in_user()
        |> post(~p"/ui/state", %{"name" => "sidebar_open", "value" => "true"})

      assert conn.status == 204
      assert get_session(conn, "sidebar_open") == true
    end

    test "handles string 'false' value", %{conn: conn} do
      conn =
        conn
        |> log_in_user()
        |> post(~p"/ui/state", %{"name" => "sidebar_open", "value" => "false"})

      assert conn.status == 204
      assert get_session(conn, "sidebar_open") == false
    end

    test "updates a custom allowed persisted state", %{conn: conn} do
      if Enum.empty?(@custom_states) do
        # If no custom states are configured, we skip this test to avoid false failures.
        IO.warn(
          "No custom persistence states configured, skipping test for custom state update. " <>
            "To test this functionality, add a custom state to the :custom_persistence_states config."
        )

        assert true
      else
        conn =
          conn
          |> log_in_user()
          |> post(~p"/ui/state", %{"name" => @custom_state, "value" => true})

        assert conn.status == 204
        assert get_session(conn, @custom_state) == true
      end
    end

    test "returns 400 for invalid request body", %{conn: conn} do
      conn =
        conn
        |> log_in_user()
        |> post(~p"/ui/state", %{"invalid" => "data"})

      assert conn.status == 400
      assert json_response(conn, 400)["error"] =~ "Invalid request"
    end

    test "returns 400 for missing name parameter", %{conn: conn} do
      conn =
        conn
        |> log_in_user()
        |> post(~p"/ui/state", %{"value" => true})

      assert conn.status == 400
    end

    test "returns 400 for missing value parameter", %{conn: conn} do
      conn =
        conn
        |> log_in_user()
        |> post(~p"/ui/state", %{"name" => "sidebar_open"})

      assert conn.status == 400
    end

    test "returns 400 for disallowed state name", %{conn: conn} do
      conn =
        conn
        |> log_in_user()
        |> post(~p"/ui/state", %{"name" => "admin_mode", "value" => true})

      assert conn.status == 400
      assert json_response(conn, 400)["error"] =~ "Invalid request"
    end

    test "requires authentication", %{conn: conn} do
      conn = post(conn, ~p"/ui/state", %{"name" => "sidebar_open", "value" => true})

      assert redirected_to(conn) == ~p"/users/log_in"
    end

    test "persists state across requests", %{conn: conn} do
      conn1 =
        conn
        |> log_in_user()
        |> post(~p"/ui/state", %{"name" => "sidebar_open", "value" => false})

      assert conn1.status == 204
      assert get_session(conn1, "sidebar_open") == false

      conn2 =
        conn1
        |> recycle()
        |> post(~p"/ui/state", %{"name" => "sidebar_open", "value" => true})

      assert conn2.status == 204
      assert get_session(conn2, "sidebar_open") == true
    end
  end
end
