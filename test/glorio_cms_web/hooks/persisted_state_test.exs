defmodule ScalesCmsWeb.Hooks.PersistedStateTest do
  use ExUnit.Case, async: true

  alias ScalesCmsWeb.Hooks.PersistedState

  defp clear_ets_table(_context) do
    case :ets.whereis(ScalesCmsWeb.PersistedStateStore.table()) do
      :undefined -> :ok
      _ -> :ets.delete_all_objects(ScalesCmsWeb.PersistedStateStore.table())
    end

    :ok
  end

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

  describe "copy_session/2" do
    test "copies only the requested session keys" do
      conn =
        Phoenix.ConnTest.build_conn()
        |> Plug.Test.init_test_session(%{
          "sidebar_open" => true,
          "filters_open" => false,
          "ignored_key" => "value"
        })

      assert PersistedState.copy_session(conn, ["sidebar_open", "filters_open"]) == %{
               "sidebar_open" => true,
               "filters_open" => false
             }
    end
  end

  describe "on_mount/4" do
    setup [:clear_ets_table]

    test "assigns persisted state from session when true" do
      socket = build_socket()
      session = %{"sidebar_open" => true}

      {:cont, updated_socket} =
        PersistedState.on_mount(
          [name: :sidebar_open, session_key: "sidebar_open", default: true],
          %{},
          session,
          socket
        )

      assert updated_socket.assigns.sidebar_open == true
    end

    test "assigns persisted state from session when false" do
      socket = build_socket()
      session = %{"sidebar_open" => false}

      {:cont, updated_socket} =
        PersistedState.on_mount(
          [name: :sidebar_open, session_key: "sidebar_open", default: true],
          %{},
          session,
          socket
        )

      assert updated_socket.assigns.sidebar_open == false
    end

    test "defaults when session has no key" do
      socket = build_socket()
      session = %{}

      {:cont, updated_socket} =
        PersistedState.on_mount(
          [name: :sidebar_open, session_key: "sidebar_open", default: true],
          %{},
          session,
          socket
        )

      assert updated_socket.assigns.sidebar_open == true
    end

    test "normalizes string 'true' to boolean true" do
      socket = build_socket()
      session = %{"sidebar_open" => "true"}

      {:cont, updated_socket} =
        PersistedState.on_mount(
          [name: :sidebar_open, session_key: "sidebar_open", default: true],
          %{},
          session,
          socket
        )

      assert updated_socket.assigns.sidebar_open == true
    end

    test "normalizes string 'false' to boolean false" do
      socket = build_socket()
      session = %{"sidebar_open" => "false"}

      {:cont, updated_socket} =
        PersistedState.on_mount(
          [name: :sidebar_open, session_key: "sidebar_open", default: true],
          %{},
          session,
          socket
        )

      assert updated_socket.assigns.sidebar_open == false
    end

    test "defaults for invalid session values when default is boolean" do
      socket = build_socket()
      session = %{"sidebar_open" => "invalid"}

      {:cont, updated_socket} =
        PersistedState.on_mount(
          [name: :sidebar_open, session_key: "sidebar_open", default: true],
          %{},
          session,
          socket
        )

      assert updated_socket.assigns.sidebar_open == true
    end

    test "defaults for nil session value" do
      socket = build_socket()
      session = %{"sidebar_open" => nil}

      {:cont, updated_socket} =
        PersistedState.on_mount(
          [name: :sidebar_open, session_key: "sidebar_open", default: true],
          %{},
          session,
          socket
        )

      assert updated_socket.assigns.sidebar_open == true
    end

    test "always returns :cont tuple" do
      socket = build_socket()

      {status, _socket} =
        PersistedState.on_mount(
          [name: :sidebar_open, session_key: "sidebar_open", default: true],
          %{},
          %{},
          socket
        )

      assert status == :cont
    end

    test "stores and reuses ETS value over session value" do
      socket1 = build_socket()
      session1 = %{"sidebar_open" => false}

      {:cont, mounted_socket} =
        PersistedState.on_mount(
          [name: :sidebar_open, session_key: "sidebar_open", default: true],
          %{},
          session1,
          socket1
        )

      assert mounted_socket.assigns.sidebar_open == false

      ets_scope = PersistedState.stable_scope(mounted_socket)
      PersistedState.update_state(ets_scope, :sidebar_open, true)

      socket2 = build_socket()
      session2 = %{"sidebar_open" => false}

      {:cont, updated_socket} =
        PersistedState.on_mount(
          [name: :sidebar_open, session_key: "sidebar_open", default: true],
          %{},
          session2,
          socket2
        )

      assert updated_socket.assigns.sidebar_open == true
    end
  end

  describe "update_state/3 and get_state/3" do
    setup [:clear_ets_table]

    test "stores and retrieves state from ETS" do
      PersistedState.update_state("user:123", :sidebar_open, false)

      assert PersistedState.get_state("user:123", :sidebar_open, true) == false
    end

    test "returns provided default when ETS value is missing" do
      assert PersistedState.get_state("user:missing", :sidebar_open, true) == true
      assert PersistedState.get_state("user:missing", :filters_open, false) == false
    end
  end

  describe "stable_scope/1" do
    test "uses current_user id when present" do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{current_user: %{id: 123}},
        private: %{}
      }

      assert PersistedState.stable_scope(socket) == "user:123"
    end

    test "falls back to live_socket_id when user is absent" do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{},
        private: %{live_socket_id: "lv:abc"}
      }

      assert PersistedState.stable_scope(socket) == "lv:abc"
    end

    test "falls back to socket.id when live_socket_id is absent" do
      socket = %Phoenix.LiveView.Socket{
        id: "phx-123",
        assigns: %{},
        private: %{}
      }

      assert PersistedState.stable_scope(socket) == "phx-123"
    end
  end
end
