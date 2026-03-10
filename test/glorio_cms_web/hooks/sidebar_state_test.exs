defmodule ScalesCmsWeb.Hooks.SidebarStateTest do
  use ExUnit.Case, async: true

  alias ScalesCmsWeb.Hooks.SidebarState

  defp clear_ets_table(_conn) do
    case :ets.whereis(:sidebar_state) do
      :undefined -> :ok
      _ -> :ets.delete_all_objects(:sidebar_state)
    end

    :ok
  end

  describe "session_key/0" do
    test "returns the expected session key" do
      assert SidebarState.session_key() == "sidebar_open"
    end
  end

  describe "default_state/0" do
    test "returns true (sidebar open by default)" do
      assert SidebarState.default_state() == true
    end
  end

  describe "on_mount/4" do
    setup [:clear_ets_table]
    # Helper to create a properly initialized socket for testing
    defp build_socket do
      %Phoenix.LiveView.Socket{
        assigns: %{__changed__: %{}},
        private: %{
          lifecycle: %Phoenix.LiveView.Lifecycle{
            handle_params: [],
            handle_event: [],
            handle_info: [],
            handle_async: [],
            after_render: [],
            mount: []
          }
        }
      }
    end

    test "assigns sidebar_open from session when true" do
      socket = build_socket()
      session = %{"sidebar_open" => true}

      {:cont, updated_socket} = SidebarState.on_mount(:default, %{}, session, socket)

      assert updated_socket.assigns.sidebar_open == true
    end

    test "assigns sidebar_open from session when false" do
      socket = build_socket()
      session = %{"sidebar_open" => false}

      {:cont, updated_socket} = SidebarState.on_mount(:default, %{}, session, socket)

      assert updated_socket.assigns.sidebar_open == false
    end

    test "defaults to true when session has no sidebar_open key" do
      socket = build_socket()
      session = %{}

      {:cont, updated_socket} = SidebarState.on_mount(:default, %{}, session, socket)

      assert updated_socket.assigns.sidebar_open == true
    end

    test "normalizes string 'true' to boolean true" do
      socket = build_socket()
      session = %{"sidebar_open" => "true"}

      {:cont, updated_socket} = SidebarState.on_mount(:default, %{}, session, socket)

      assert updated_socket.assigns.sidebar_open == true
    end

    test "normalizes string 'false' to boolean false" do
      socket = build_socket()
      session = %{"sidebar_open" => "false"}

      {:cont, updated_socket} = SidebarState.on_mount(:default, %{}, session, socket)

      assert updated_socket.assigns.sidebar_open == false
    end

    test "defaults to true for invalid session values" do
      socket = build_socket()
      session = %{"sidebar_open" => "invalid"}

      {:cont, updated_socket} = SidebarState.on_mount(:default, %{}, session, socket)

      assert updated_socket.assigns.sidebar_open == true
    end

    test "defaults to true for nil session value" do
      socket = build_socket()
      session = %{"sidebar_open" => nil}

      {:cont, updated_socket} = SidebarState.on_mount(:default, %{}, session, socket)

      assert updated_socket.assigns.sidebar_open == true
    end

    test "always returns :cont tuple" do
      socket = build_socket()

      {status, _socket} = SidebarState.on_mount(:default, %{}, %{}, socket)

      assert status == :cont
    end
  end
end
