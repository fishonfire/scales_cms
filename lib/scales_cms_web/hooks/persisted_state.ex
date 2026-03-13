defmodule ScalesCmsWeb.Hooks.PersistedState do
  @moduledoc """
  Generic LiveView `on_mount` hook for managing persisted UI state.

  This hook manages a named piece of state with two-tier storage:

  1. Session storage - persistence across full page refreshes
  2. ETS storage - persistence across LiveView navigations and reconnects

  This is useful for UI state like:

  - sidebar open/closed
  - panel expansion
  - selected tabs
  - layout mode
  - filter drawer visibility

  ## Usage

  In the router:

      live_session :default,
        on_mount: [
          {ScalesCmsWeb.UserAuth, :ensure_authenticated},
          {ScalesCmsWeb.Hooks.PersistedState,
           [name: :sidebar_open, session_key: "sidebar_open", default: true]}
        ],
        session: {ScalesCmsWeb.Hooks.PersistedState, :copy_session, [["sidebar_open"]]} do
        live "/dashboard", DashboardLive
      end

  In the LiveView or LiveComponent:

      push_event(socket, "update_persisted_state", %{
        "name" => "sidebar_open",
        "value" => false
      })

  Or send a message:

      send(self(), {:update_persisted_state, :sidebar_open, false})

  ## Socket assigns

  The hook assigns the state directly under its configured name:

      socket.assigns.sidebar_open

  It also stores internal metadata in:

      socket.assigns.__persisted_state_keys__
  """

  import Phoenix.Component, only: [assign: 3]
  import Phoenix.LiveView, only: [attach_hook: 4]

  @ets_table ScalesCmsWeb.PersistedStateStore.table()

  @doc """
  Copies the given session keys from Plug session into LiveView session.

  ## Example

      live_session :default,
        session: {ScalesCmsWeb.Hooks.PersistedState, :copy_session, [["sidebar_open", "filters_open"]]}
  """
  def copy_session(conn, keys) when is_list(keys) do
    Map.new(keys, fn key ->
      {key, Plug.Conn.get_session(conn, key)}
    end)
  end

  @doc """
  Mounts persisted state.

  Expected options:

    * `:name` - atom assign name, e.g. `:sidebar_open`
    * `:session_key` - session key string, e.g. `"sidebar_open"`
    * `:default` - default value when nothing is stored
    * `:normalize` - optional 1-arity function for coercing session values

  ## Example

      {ScalesCmsWeb.Hooks.PersistedState,
       [name: :sidebar_open, session_key: "sidebar_open", default: true]}
  """
  def on_mount(opts, _params, session, socket) when is_list(opts) do
    ensure_ets_table_exists()

    name = Keyword.fetch!(opts, :name)
    session_key = Keyword.fetch!(opts, :session_key)
    default = Keyword.fetch!(opts, :default)
    normalize = Keyword.get(opts, :normalize, &default_normalizer(&1, default))

    ets_scope = get_stable_ets_scope(socket)
    ets_key = build_ets_key(ets_scope, name)

    value =
      case get_from_ets(ets_key) do
        {:ok, value} ->
          value

        :not_found ->
          value =
            session
            |> Map.get(session_key, default)
            |> normalize.()

          put_in_ets(ets_key, value)
          value
      end

    state_keys =
      socket.assigns
      |> Map.get(:__persisted_state_keys__, %{})
      |> Map.put(name, ets_key)

    socket =
      socket
      |> assign(name, value)
      |> assign(:__persisted_state_keys__, state_keys)
      |> attach_hook(
        :"persisted_state_sync_#{name}",
        :handle_event,
        &handle_persisted_state_event/3
      )
      |> attach_hook(
        :"persisted_state_info_#{name}",
        :handle_info,
        &handle_persisted_state_info/2
      )

    {:cont, socket}
  end

  @doc """
  Updates a named state value in ETS.
  """
  def update_state(ets_scope, name, value) do
    ensure_ets_table_exists()
    put_in_ets(build_ets_key(ets_scope, name), value)
  end

  @doc """
  Gets a named state value from ETS, returning `default` if missing.
  """
  def get_state(ets_scope, name, default) do
    ensure_ets_table_exists()

    case get_from_ets(build_ets_key(ets_scope, name)) do
      {:ok, value} -> value
      :not_found -> default
    end
  end

  @doc """
  Returns the stable ETS scope for a socket.

  Authenticated users get a stable user-based scope.
  Unauthenticated users fall back to a socket-based scope.
  """
  def stable_scope(socket), do: get_stable_ets_scope(socket)

  defp get_stable_ets_scope(socket) do
    if Map.has_key?(socket.assigns, :current_user) && socket.assigns.current_user != nil do
      "user:#{socket.assigns.current_user.id}"
    else
      socket.private[:live_socket_id] || socket.id
    end
  end

  defp build_ets_key(scope, name), do: "#{scope}:#{name}"

  defp handle_persisted_state_event(
         "update_persisted_state",
         %{"name" => name, "value" => value},
         socket
       ) do
    name = normalize_name(name)

    case socket.assigns[:__persisted_state_keys__] do
      %{^name => ets_key} = _keys ->
        update_state_by_key(ets_key, value)
        {:cont, assign(socket, name, value)}

      _ ->
        {:cont, socket}
    end
  end

  defp handle_persisted_state_event(_event, _params, socket) do
    {:cont, socket}
  end

  defp handle_persisted_state_info({:update_persisted_state, name, value}, socket) do
    name = normalize_name(name)

    case socket.assigns[:__persisted_state_keys__] do
      %{^name => ets_key} = _keys ->
        update_state_by_key(ets_key, value)
        {:halt, assign(socket, name, value)}

      _ ->
        {:cont, socket}
    end
  end

  defp handle_persisted_state_info(_message, socket) do
    {:cont, socket}
  end

  defp normalize_name(name) when is_atom(name), do: name
  defp normalize_name(name) when is_binary(name), do: String.to_existing_atom(name)

  defp update_state_by_key(ets_key, value) do
    ensure_ets_table_exists()
    put_in_ets(ets_key, value)
  end

  defp default_normalizer(value, default) when is_boolean(default) do
    case value do
      true -> true
      false -> false
      "true" -> true
      "false" -> false
      _ -> default
    end
  end

  defp default_normalizer(value, _default), do: value

  defp ensure_ets_table_exists do
    case :ets.whereis(@ets_table) do
      :undefined ->
        raise """
        ETS table #{@ets_table} is missing.
        Expected it to be started by ScalesCmsWeb.PersistedState.
        """

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
end
