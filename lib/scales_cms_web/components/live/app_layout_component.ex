defmodule ScalesCmsWeb.Live.AppLayoutComponent do
  @moduledoc """
  Main layout component that wraps all CMS pages.
  """

  use ScalesCmsWeb, :live_component

  @sidebar_enabled Application.compile_env(:scales_cms, :enabled_sidebar, true)

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)

    socket =
      if @sidebar_enabled do
        assign_new(socket, :sidebar_open, fn -> true end)
      else
        socket
      end

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("toggle-sidebar", _params, socket) do
    new_state = !socket.assigns.sidebar_open

    send(self(), {:update_persisted_state, :sidebar_open, new_state})

    socket
    |> assign(:sidebar_open, new_state)
    |> push_event("persisted-state-changed", %{name: :sidebar_open, value: new_state})
    |> then(&{:noreply, &1})
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    if @sidebar_enabled do
      render_with_sidebar(assigns)
    else
      render_without_sidebar(assigns)
    end
  end

  defp render_with_sidebar(assigns) do
    ~H"""
    <div
      id="app-layout"
      class="app-layout"
      phx-hook="PersistedState"
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
        class={"main-content has-sidebar #{if @sidebar_open, do: "", else: "sidebar-closed"}"}
      >
        <.flash_group flash={@inner_flash} />
        {render_slot(@inner_block)}
      </main>
    </div>
    """
  end

  defp render_without_sidebar(assigns) do
    ~H"""
    <div id="app-layout" class="app-layout no-sidebar">
      <main id="main-content" class="main-content">
        <.flash_group flash={@inner_flash} />
        {render_slot(@inner_block)}
      </main>
    </div>
    """
  end
end
