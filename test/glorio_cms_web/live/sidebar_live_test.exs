defmodule ScalesCmsWeb.SidebarLiveTest do
  use ScalesCmsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias ScalesCmsWeb.Hooks.SidebarState

  # Helper to log in user with optional sidebar state
  # Note: Phoenix sessions use string keys, so we use the string key from SidebarState
  defp log_in_with_sidebar(conn, sidebar_open) do
    conn
    |> Phoenix.ConnTest.init_test_session(%{
      "user_token" => "bla_bla_bla",
      SidebarState.session_key() => sidebar_open
    })
  end

  describe "sidebar state from session" do
    test "renders sidebar open by default when no session value", %{conn: conn} do
      conn = log_in_user(conn)

      {:ok, _view, html} = live(conn, ~p"/cms")

      # Sidebar should be open (no "closed" class)
      assert html =~ ~s(id="default-sidebar")
      assert html =~ ~s(data-sidebar-open="true")
      refute html =~ ~s(class="sidebar closed")
    end

    test "renders sidebar closed when session has sidebar_open = false", %{conn: conn} do
      conn = log_in_with_sidebar(conn, false)

      {:ok, _view, html} = live(conn, ~p"/cms")

      # Sidebar should be closed
      assert html =~ ~s(class="sidebar closed")
      assert html =~ ~s(data-sidebar-open="false")
    end

    test "renders sidebar open when session has sidebar_open = true", %{conn: conn} do
      conn = log_in_with_sidebar(conn, true)

      {:ok, _view, html} = live(conn, ~p"/cms")

      # Sidebar should be open (no "closed" class)
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

      # Main content should not have sidebar-closed class
      refute html =~ "sidebar-closed"
    end
  end

  describe "sidebar toggle interaction" do
    test "clicking toggle button closes sidebar when open", %{conn: conn} do
      conn = log_in_with_sidebar(conn, true)

      {:ok, view, _html} = live(conn, ~p"/cms")

      # Click the toggle button
      html =
        view
        |> element("button[aria-controls='default-sidebar']")
        |> render_click()

      # Sidebar should now be closed
      assert html =~ ~s(class="sidebar closed")
    end

    test "clicking toggle button opens sidebar when closed", %{conn: conn} do
      conn = log_in_with_sidebar(conn, false)

      {:ok, view, _html} = live(conn, ~p"/cms")

      # Click the toggle button
      html =
        view
        |> element("button[aria-controls='default-sidebar']")
        |> render_click()

      # Sidebar should now be open (no "closed" class)
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

      # Initially aria-expanded should be true
      assert html =~ ~s(aria-expanded="true")

      # Click the toggle button
      html =
        view
        |> element("button[aria-controls='default-sidebar']")
        |> render_click()

      # After click, aria-expanded should be false
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

    test "SidebarState hook is attached to app-layout", %{conn: conn} do
      conn = log_in_user(conn)

      {:ok, _view, html} = live(conn, ~p"/cms")

      assert html =~ ~s(phx-hook="SidebarState")
    end

    test "data-sidebar-open updates after toggle", %{conn: conn} do
      conn = log_in_with_sidebar(conn, true)

      {:ok, view, html} = live(conn, ~p"/cms")

      # Initially should be true
      assert html =~ ~s(data-sidebar-open="true")

      # Click the toggle button
      html =
        view
        |> element("button[aria-controls='default-sidebar']")
        |> render_click()

      # After click, should be false
      assert html =~ ~s(data-sidebar-open="false")
    end
  end

  describe "sidebar state persistence across navigation" do
    test "sidebar state persists when navigating via live_patch", %{conn: conn} do
      conn = log_in_with_sidebar(conn, true)

      # Start with sidebar open on the directories page (which has navigation links)
      {:ok, view, html} = live(conn, ~p"/cms/directories")
      assert html =~ ~s(data-sidebar-open="true")

      # Close the sidebar
      html =
        view
        |> element("button[aria-controls='default-sidebar']")
        |> render_click()

      assert html =~ ~s(data-sidebar-open="false")
      assert html =~ ~s(class="sidebar closed")

      # Navigate using live_patch (to a subdirectory or with query params)
      # The sidebar state should persist because we're staying in the same LiveView process
      html = render_patch(view, ~p"/cms/directories?query=test")

      # The sidebar should still be closed
      assert html =~ ~s(data-sidebar-open="false")
      assert html =~ ~s(class="sidebar closed")
    end

    test "toggling sidebar multiple times works correctly", %{conn: conn} do
      conn = log_in_with_sidebar(conn, true)

      {:ok, view, html} = live(conn, ~p"/cms")

      # Initially open
      assert html =~ ~s(data-sidebar-open="true")

      # Close
      html =
        view
        |> element("button[aria-controls='default-sidebar']")
        |> render_click()

      assert html =~ ~s(data-sidebar-open="false")

      # Open again
      html =
        view
        |> element("button[aria-controls='default-sidebar']")
        |> render_click()

      assert html =~ ~s(data-sidebar-open="true")

      # Close again
      html =
        view
        |> element("button[aria-controls='default-sidebar']")
        |> render_click()

      assert html =~ ~s(data-sidebar-open="false")
    end
  end
end
