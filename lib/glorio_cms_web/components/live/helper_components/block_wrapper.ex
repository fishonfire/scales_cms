defmodule GlorioCmsWeb.Components.HelperComponents.BlockWrapper do
  use GlorioCmsWeb, :live_component

  @impl true
  def mount(socket) do
    socket
    |> assign(:closed, true)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("toggle-open", _, socket) do
    {:noreply, assign(socket, :closed, !socket.assigns.closed)}
  end

  slot :inner_block, required: true
  attr :block, GlorioCms.Cms.CmsPageVariantBlock

  def render(assigns) do
    ~H"""
    <div>
      <div class="w-full flex justify-between">
        <div class="drag-handle w-[24px] h-[24px]">
          <.svg type="drag_handle" class="w-[24px] h-[24px]" />
        </div>
        <div>
          <%= @block.component_type %>
        </div>
        <div>
          <span phx-click="delete" phx-value-id={@block.id}>delete</span>
        </div>
        <div phx-click="toggle-open" phx-target={@myself} class="w-[24px] h-[24px] justify-self-end">
          <.svg
            type="toggle_up"
            class={"w-[16px] h-[16px] mt-[4px] transition-all	 #{if @closed, do: "rotate-180", else: ""}"}
          />
        </div>
      </div>
      <div :if={!@closed} class="border-2">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
