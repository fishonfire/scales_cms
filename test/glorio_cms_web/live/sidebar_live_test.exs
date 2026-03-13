defmodule ScalesCmsWeb.SidebarLiveTest do
  use ScalesCmsWeb.ConnCase

  import Phoenix.LiveViewTest

  defp log_in_with_sidebar(conn, sidebar_open) do
    conn
    |> Phoenix.ConnTest.init_test_session(%{
      "user_token" => "bla_bla_bla",
      "sidebar_open" => sidebar_open
    })
  end

  defp clear_sidebar_ets(_context) do
    case :ets.whereis(ScalesCmsWeb.PersistedStateStore.table()) do
      :undefined ->
        :ok

      _tid ->
        :ets.delete_all_objects(ScalesCmsWeb.PersistedStateStore.table())
    end

    :ok
  end

  describe "sidebar state from session" do
    setup [:clear_sidebar_ets]

    test "renders sidebar open by default when no session value", %{conn: conn} do
      conn = log_in_user(conn)

      {:ok, _view, html} = live(conn, ~p"/cms")

      assert html =~ ~s(id="default-sidebar")
      assert html =~ ~s(data-sidebar-open="true")
      refute html =~ ~s(class="sidebar closed")
    end

    test "renders sidebar closed when session has sidebar_open = false", %{conn: conn} do
      conn = log_in_with_sidebar(conn, false)

      {:ok, _view, html} = live(conn, ~p"/cms")

      assert html =~ ~s(class="sidebar closed")
      assert html =~ ~s(data-sidebar-open="false")
    end

    test "renders sidebar open when session has sidebar_open = true", %{conn: conn} do
      conn = log_in_with_sidebar(conn, true)

      {:ok, _view, html} = live(conn, ~p"/cms")

      assert html =~ ~s(data-sidebar-open="true")
      refute html =~ ~s(class="sidebar closed")
    end

    test "main content has sidebar-closed class when sidebar is closed", %{conn: conn} do
      conn = log_in_with_sidebar(conn, false)

      {:ok, _view, html} = live(conn, ~p"/cms")

      assert html =~ ~s(class="sidebar closed")
      assert html =~ "sidebar-closed"
    end

    test "main content has no sidebar-closed class when sidebar is open", %{conn: conn} do
      conn = log_in_with_sidebar(conn, true)

      {:ok, _view, html} = live(conn, ~p"/cms")

      refute html =~ "sidebar-closed"
    end
  end

  describe "sidebar toggle interaction" do
    setup [:clear_sidebar_ets]

    test "clicking toggle button closes sidebar when open", %{conn: conn} do
      conn = log_in_with_sidebar(conn, true)

      {:ok, view, _html} = live(conn, ~p"/cms")

      html =
        view
        |> element("button[aria-controls='default-sidebar']")
        |> render_click()

      assert html =~ ~s(class="sidebar closed")
    end

    test "clicking toggle button opens sidebar when closed", %{conn: conn} do
      conn = log_in_with_sidebar(conn, false)

      {:ok, view, _html} = live(conn, ~p"/cms")

      html =
        view
        |> element("button[aria-controls='default-sidebar']")
        |> render_click()

      refute html =~ ~s(class="sidebar closed")
    end

    test "toggle button has correct aria-expanded when sidebar is open", %{conn: conn} do
      conn = log_in_with_sidebar(conn, true)

      {:ok, _view, html} = live(conn, ~p"/cms")

      assert html =~ ~s(aria-expanded="true")
    end

    test "toggle button has correct aria-expanded when sidebar is closed", %{conn: conn} do
      conn = log_in_with_sidebar(conn, false)

      {:ok, _view, html} = live(conn, ~p"/cms")

      assert html =~ ~s(aria-expanded="false")
    end

    test "toggle button updates aria-expanded after click", %{conn: conn} do
      conn = log_in_with_sidebar(conn, true)

      {:ok, view, html} = live(conn, ~p"/cms")

      assert html =~ ~s(aria-expanded="true")

      html =
        view
        |> element("button[aria-controls='default-sidebar']")
        |> render_click()

      assert html =~ ~s(aria-expanded="false")
    end

    test "sidebar has stable id for accessibility", %{conn: conn} do
      conn = log_in_user(conn)

      {:ok, _view, html} = live(conn, ~p"/cms")

      assert html =~ ~s(id="default-sidebar")
    end

    test "toggle button has aria-controls pointing to sidebar", %{conn: conn} do
      conn = log_in_user(conn)

      {:ok, _view, html} = live(conn, ~p"/cms")

      assert html =~ ~s(aria-controls="default-sidebar")
    end
  end

  describe "sidebar state data attribute" do
    setup [:clear_sidebar_ets]

    test "app-layout has data-sidebar-open attribute matching state when open", %{conn: conn} do
      conn = log_in_with_sidebar(conn, true)

      {:ok, _view, html} = live(conn, ~p"/cms")

      assert html =~ ~s(data-sidebar-open="true")
    end

    test "data-sidebar-open is false when sidebar is closed", %{conn: conn} do
      conn = log_in_with_sidebar(conn, false)

      {:ok, _view, html} = live(conn, ~p"/cms")

      assert html =~ ~s(data-sidebar-open="false")
    end

    test "PersistedState hook is attached to app-layout", %{conn: conn} do
      conn = log_in_user(conn)

      {:ok, _view, html} = live(conn, ~p"/cms")

      assert html =~ ~s(phx-hook="PersistedState")
    end

    test "data-sidebar-open updates after toggle", %{conn: conn} do
      conn = log_in_with_sidebar(conn, true)

      {:ok, view, html} = live(conn, ~p"/cms")

      assert html =~ ~s(data-sidebar-open="true")

      html =
        view
        |> element("button[aria-controls='default-sidebar']")
        |> render_click()

      assert html =~ ~s(data-sidebar-open="false")
    end
  end

  describe "sidebar state persistence across navigation" do
    setup [:clear_sidebar_ets]

    test "sidebar state persists when navigating via live_patch", %{conn: conn} do
      conn = log_in_with_sidebar(conn, true)

      {:ok, view, html} = live(conn, ~p"/cms/directories")
      assert html =~ ~s(data-sidebar-open="true")

      html =
        view
        |> element("button[aria-controls='default-sidebar']")
        |> render_click()

      assert html =~ ~s(data-sidebar-open="false")
      assert html =~ ~s(class="sidebar closed")

      html = render_patch(view, ~p"/cms/directories?query=test")

      assert html =~ ~s(data-sidebar-open="false")
      assert html =~ ~s(class="sidebar closed")
    end

    test "toggling sidebar multiple times works correctly", %{conn: conn} do
      conn = log_in_with_sidebar(conn, true)

      {:ok, view, html} = live(conn, ~p"/cms")

      assert html =~ ~s(data-sidebar-open="true")

      html =
        view
        |> element("button[aria-controls='default-sidebar']")
        |> render_click()

      assert html =~ ~s(data-sidebar-open="false")

      html =
        view
        |> element("button[aria-controls='default-sidebar']")
        |> render_click()

      assert html =~ ~s(data-sidebar-open="true")

      html =
        view
        |> element("button[aria-controls='default-sidebar']")
        |> render_click()

      assert html =~ ~s(data-sidebar-open="false")
    end
  end
end
