defmodule ScalesCmsWeb.Live.AppLayoutComponent do
  @moduledoc """
    Main layout component
    Currently only keeps track of sidebar opened and closed
  """
  use ScalesCmsWeb, :live_component

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    assigns = assigns |> Map.put_new(:sidebar_open, true)

    socket
    |> assign(assigns)
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveComponent
  def handle_event("toggle-sidebar", _params, socket) do
    socket
    |> assign(:sidebar_open, !socket.assigns.sidebar_open)
    |> then(&{:noreply, &1})
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div id="app-layout" class="app-layout">
      <aside
        id="default-sidebar"
        class={"sidebar #{if @sidebar_open, do: "", else: "closed"}"}
        aria-label="Sidebar"
      >
        <div class="scales-logo p-3">
          <.svg type="scales_logo" width="160" height="40" class="mx-auto" />
        </div>

        <div class="chevron-container">
          <div class="chevron-wrapper" phx-click="toggle-sidebar" phx-target={@myself}>
            <.svg type="chevron" id="chevron" width="12" height="12" />
          </div>
        </div>

        <ScalesCmsWeb.Components.MenuItems.render />
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
