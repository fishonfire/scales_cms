defmodule ScalesCmsWeb.Hooks.SidebarState do
  @moduledoc """
  LiveView on_mount hook for managing sidebar state.

  This hook manages the sidebar open/closed state with two-tier storage:
  1. **Session storage** - For persistence across page refreshes (HTTP boundary)
  2. **ETS storage** - For persistence across LiveView navigations (WebSocket)

  This ensures the sidebar state is preserved both when navigating between
  LiveViews (client-side navigation) and when doing full page refreshes.

  ## Session Key

  The sidebar state is stored in the session under the key `"sidebar_open"`.

  ## Default State

  When no session value exists, the sidebar defaults to **open** (`true`).
  This provides a good first-time user experience with full navigation visible.

  ## Usage

  Add this hook to your `live_session` in the router:

      live_session :my_session, on_mount: [{ScalesCmsWeb.Hooks.SidebarState, :default}] do
        live "/path", MyLive
      end

  Or combine with other hooks:

      live_session :my_session,
        on_mount: [
          {ScalesCmsWeb.UserAuth, :ensure_authenticated},
          {ScalesCmsWeb.Hooks.SidebarState, :default}
        ] do
        live "/path", MyLive
      end
  """

  import Phoenix.Component, only: [assign: 3]
  import Phoenix.LiveView, only: [attach_hook: 4]

  @session_key "sidebar_open"
  @default_state true
  @ets_table :sidebar_state

  @doc """
  Returns the session key used to store sidebar state.
  Useful for controllers that need to update the session.
  """
  def session_key, do: @session_key

  @doc """
  Returns the default sidebar state (true = open).
  """
  def default_state, do: @default_state

  @doc """
  Extracts sidebar state from Plug session for LiveView session.

  This function is called by the live_session :session option (MFA format)
  to copy the sidebar_open value from the Plug session to the LiveView session.

  ## Example

      live_session :my_session,
        session: {ScalesCmsWeb.Hooks.SidebarState, :copy_session, []}
  """
  def copy_session(conn) do
    %{
      @session_key => Plug.Conn.get_session(conn, @session_key)
    }
  end

  @doc """
  Mounts the sidebar state from session into socket assigns.

  On initial mount, reads from session and stores in ETS for the live_socket_id.
  On subsequent LiveView navigations, reads from ETS to get the current state
  (which may have been updated by toggle events).

  This ensures toggling the sidebar persists across client-side navigations.
  """
  def on_mount(:default, _params, session, socket) do
    ensure_ets_table_exists()

    live_socket_id = socket.private[:live_socket_id] || socket.id

    sidebar_open =
      case get_from_ets(live_socket_id) do
        {:ok, value} ->
          # Found in ETS - use the current in-memory state
          value

        :not_found ->
          # Not in ETS - read from session and store in ETS
          value =
            session
            |> Map.get(@session_key, @default_state)
            |> normalize_sidebar_state()

          put_in_ets(live_socket_id, value)
          value
      end

    socket =
      socket
      |> assign(:sidebar_open, sidebar_open)
      |> assign(:__sidebar_live_socket_id__, live_socket_id)
      |> attach_hook(:sidebar_state_sync, :handle_event, &handle_sidebar_event/3)
      |> attach_hook(:sidebar_state_info, :handle_info, &handle_sidebar_info/2)

    {:cont, socket}
  end

  @doc """
  Updates the sidebar state in ETS.

  Called by LiveView/LiveComponent when the sidebar is toggled.
  This ensures the new state persists across LiveView navigations.
  """
  def update_state(live_socket_id, open) when is_boolean(open) do
    ensure_ets_table_exists()
    put_in_ets(live_socket_id, open)
  end

  @doc """
  Gets the current sidebar state from ETS.
  """
  def get_state(live_socket_id) do
    ensure_ets_table_exists()

    case get_from_ets(live_socket_id) do
      {:ok, value} -> value
      :not_found -> @default_state
    end
  end

  # Handle sidebar toggle events at the LiveView level to sync ETS
  defp handle_sidebar_event("update_sidebar_state", %{"open" => open}, socket) do
    live_socket_id = socket.assigns[:__sidebar_live_socket_id__]

    if live_socket_id do
      update_state(live_socket_id, open)
    end

    {:cont, assign(socket, :sidebar_open, open)}
  end

  defp handle_sidebar_event(_event, _params, socket) do
    {:cont, socket}
  end

  # Handle sidebar state update messages from LiveComponent
  defp handle_sidebar_info({:update_sidebar_state, open}, socket) when is_boolean(open) do
    live_socket_id = socket.assigns[:__sidebar_live_socket_id__]

    if live_socket_id do
      update_state(live_socket_id, open)
    end

    {:halt, assign(socket, :sidebar_open, open)}
  end

  defp handle_sidebar_info(_message, socket) do
    {:cont, socket}
  end

  # ETS helpers

  defp ensure_ets_table_exists do
    case :ets.whereis(@ets_table) do
      :undefined ->
        # Create table if it doesn't exist
        # Using public so LiveComponents can also access it
        # Using set for simple key-value storage
        try do
          :ets.new(@ets_table, [:set, :public, :named_table])
        rescue
          ArgumentError ->
            # Table might have been created by another process between check and create
            :ok
        end

      _tid ->
        :ok
    end
  end

  defp get_from_ets(key) do
    case :ets.lookup(@ets_table, key) do
      [{^key, value}] -> {:ok, value}
      [] -> :not_found
    end
  end

  defp put_in_ets(key, value) do
    :ets.insert(@ets_table, {key, value})
  end

  # Normalize various possible session values to boolean
  # Session values may come as booleans, strings, or atoms depending on serialization
  defp normalize_sidebar_state(value) when is_boolean(value), do: value
  defp normalize_sidebar_state("true"), do: true
  defp normalize_sidebar_state("false"), do: false
  defp normalize_sidebar_state(_), do: @default_state
end
