defmodule ScalesCmsWeb.ContextMenuComponents do
  @moduledoc """
  Provides a reusable context menu component that can be used across the CMS interface tables.

  Hook for managing context menu state and events: `ScalesCmsWeb.Hooks.ContextMenu`

  JSHook for handling opening the context menu on right-click: `js/hooks/context_menu.js`
  Usage: phx-hook="ContextMenu" on the table row element.

  Usage:

      <.context_menu :if={@context_menu} id="my-context-menu" context_menu={@context_menu}>
        <:menu_slots :let={menu_context}>
          <%= if menu_context.type == "item" do %>
            <button phx-click="edit-item" phx-value-id={menu_context.id}>Edit</button>
            <button phx-click="delete-item" phx-value-id={menu_context.id}>Delete</button>
          <% end %>
        </:menu_slots>
      </.context_menu>
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :context_menu, :map, default: nil
  attr :id, :string, default: "context-menu"
  slot :menu_slots, required: true

  def context_menu(assigns) do
    ~H"""
    <div
      :if={@context_menu}
      id={@id}
      class="context-menu"
      phx-click="close-context-menu"
      phx-window-keydown="close-context-menu"
      phx-key="escape"
      phx-remove={hide_menu("##{@id}-content")}
    >
      <div
        id={"#{@id}-content"}
        class="context-menu-content"
        style={"left: #{@context_menu.x}px; top: #{@context_menu.y}px;"}
        phx-click-away="close-context-menu"
        phx-stop-propagation
        phx-mounted={show_menu("##{@id}-content")}
      >
        {render_slot(@menu_slots, @context_menu)}
      </div>
    </div>
    """
  end

  defp show_menu(selector, js \\ %JS{}) do
    JS.transition(
      js,
      {"transition ease-out duration-200", "opacity-0 scale-95 -translate-y-1",
       "opacity-100 scale-100 translate-y-0"},
      to: selector
    )
  end

  defp hide_menu(selector, js \\ %JS{}) do
    JS.transition(
      js,
      {"transition ease-in duration-150", "opacity-100 scale-100 translate-y-0",
       "opacity-0 scale-95 -translate-y-1"},
      to: selector
    )
  end
end
