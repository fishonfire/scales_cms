defmodule ScalesCmsWeb.SidebarControllerTest do
  use ScalesCmsWeb.ConnCase

  alias ScalesCmsWeb.Hooks.SidebarState

  describe "POST /ui/sidebar" do
    test "updates session with sidebar_open = true", %{conn: conn} do
      conn =
        conn
        |> log_in_user()
        |> post(~p"/ui/sidebar", %{"open" => true})

      assert conn.status == 204
      assert get_session(conn, SidebarState.session_key()) == true
    end

    test "updates session with sidebar_open = false", %{conn: conn} do
      conn =
        conn
        |> log_in_user()
        |> post(~p"/ui/sidebar", %{"open" => false})

      assert conn.status == 204
      assert get_session(conn, SidebarState.session_key()) == false
    end

    test "handles string 'true' value", %{conn: conn} do
      conn =
        conn
        |> log_in_user()
        |> post(~p"/ui/sidebar", %{"open" => "true"})

      assert conn.status == 204
      assert get_session(conn, SidebarState.session_key()) == true
    end

    test "handles string 'false' value", %{conn: conn} do
      conn =
        conn
        |> log_in_user()
        |> post(~p"/ui/sidebar", %{"open" => "false"})

      assert conn.status == 204
      assert get_session(conn, SidebarState.session_key()) == false
    end

    test "returns 400 for invalid request body", %{conn: conn} do
      conn =
        conn
        |> log_in_user()
        |> post(~p"/ui/sidebar", %{"invalid" => "data"})

      assert conn.status == 400
      assert json_response(conn, 400)["error"] =~ "Invalid request"
    end

    test "returns 400 for missing open parameter", %{conn: conn} do
      conn =
        conn
        |> log_in_user()
        |> post(~p"/ui/sidebar", %{})

      assert conn.status == 400
    end

    test "requires authentication", %{conn: conn} do
      conn = post(conn, ~p"/ui/sidebar", %{"open" => true})

      # Should redirect to login
      assert redirected_to(conn) == ~p"/users/log_in"
    end

    test "persists state across requests", %{conn: conn} do
      # First request: set to false
      conn1 =
        conn
        |> log_in_user()
        |> post(~p"/ui/sidebar", %{"open" => false})

      assert conn1.status == 204
      assert get_session(conn1, SidebarState.session_key()) == false

      # Second request: set to true
      conn2 =
        conn1
        |> recycle()
        |> post(~p"/ui/sidebar", %{"open" => true})

      assert conn2.status == 204
      assert get_session(conn2, SidebarState.session_key()) == true
    end
  end
end
