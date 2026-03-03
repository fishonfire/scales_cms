defmodule ScalesCmsWeb.Live.AppLayoutComponent do
  @moduledoc """
  Main layout component that wraps all CMS pages.

  Manages the sidebar open/closed state with the following features:
  - Reads initial state from session via on_mount hook (`:sidebar_open` assign)
  - Toggles state on user interaction with immediate UI feedback
  - Persists state changes via:
    - ETS (for LiveView navigations) - via event to parent LiveView
    - Session (for page refreshes) - via push_event + JS hook POST

  ## Sidebar State Flow

  1. Router's live_session includes `SidebarState` on_mount hook
  2. Hook reads "sidebar_open" from session/ETS, assigns to socket
  3. Layout passes `@sidebar_open` to this component
  4. On toggle:
     a. Component updates local state for immediate UI feedback
     b. Sends event to parent LiveView to update ETS (for navigation persistence)
     c. Pushes event to JS hook to POST to server (for session persistence)
  5. On LiveView navigation: hook reads from ETS (current state)
  6. On full page refresh: hook reads from session (persisted state)

  ## Default State

  The sidebar defaults to open (`true`). See `ScalesCmsWeb.Hooks.SidebarState`
  for the authoritative default.
  """
  use ScalesCmsWeb, :live_component

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    # Use sidebar_open from parent (set by on_mount hook), default to true if not present
    assigns = assigns |> Map.put_new(:sidebar_open, true)

    socket
    |> assign(assigns)
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveComponent
  def handle_event("toggle-sidebar", _params, socket) do
    new_state = !socket.assigns.sidebar_open

    # Notify parent LiveView to update ETS state (for navigation persistence)
    send(self(), {:update_sidebar_state, new_state})

    socket
    |> assign(:sidebar_open, new_state)
    # Push event to JS hook for session persistence (for page refresh)
    |> push_event("sidebar-state-changed", %{open: new_state})
    |> then(&{:noreply, &1})
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div
      id="app-layout"
      class="app-layout"
      phx-hook="SidebarState"
      data-sidebar-open={to_string(@sidebar_open)}
    >
      <aside
        id="default-sidebar"
        class={"sidebar #{if @sidebar_open, do: "", else: "closed"}"}
        aria-label="Sidebar"
        aria-hidden={to_string(!@sidebar_open)}
      >
        <div class="scales-logo p-3">
          <.svg type="scales_logo" width="160" height="40" class="mx-auto" />
        </div>

        <div class="chevron-container">
          <button
            type="button"
            class="chevron-wrapper"
            phx-click="toggle-sidebar"
            phx-target={@myself}
            aria-expanded={to_string(@sidebar_open)}
            aria-controls="default-sidebar"
            aria-label={if @sidebar_open, do: "Close sidebar", else: "Open sidebar"}
          >
            <.svg type="chevron" id="chevron" width="12" height="12" />
          </button>
        </div>

        <ScalesCmsWeb.Components.MenuItems.render
          sidebar_open={@sidebar_open}
          current_uri={@current_uri}
        />
      </aside>

      <main
        id="main-content"
        class={"main-content p-4 #{if @sidebar_open, do: "", else: "sidebar-closed"}"}
      >
        <.flash_group flash={@inner_flash} />
        {render_slot(@inner_block)}
      </main>
    </div>
    """
  end
end
