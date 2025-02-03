defmodule ScalesCmsWeb.Components.HelperComponents.BlockWrapper do
  @moduledoc """
  The wrapper that goes around a block that is rendered in the WYSIWYG editor
  """
  use ScalesCmsWeb, :live_component

  @impl Phoenix.LiveComponent
  def mount(socket) do
    socket
    |> assign(:published, false)
    |> assign(:closed, false)
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("toggle-open", _, socket) do
    {:noreply, assign(socket, :closed, !socket.assigns.closed)}
  end

  slot :inner_block, required: true
  attr :block, ScalesCms.Cms.CmsPageVariantBlock

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <div class={"#{if !@published, do: "drag-handle"} cursor-move w-full flex justify-between align-center bg-lightGrey py-[8px] transition-all ease-in-out delay-150 duration-300"}>
        <div class="align-middle ml-[12px] text-sm font-semibold leading-[32px]">
          {@component.title()}
        </div>
        <div class="flex">
          <div class="mr-[8px] bg-white rounded flex">
            <div
              :if={!@published}
              phx-click="delete"
              phx-value-id={@block.id}
              class="py-[4px] border-r-2 cursor-pointer flex items-center justify-center p-2"
            >
              <.icon name="hero-trash" class="icon-small" />
            </div>
            <div
              phx-click="toggle-open"
              phx-target={@myself}
              class="py-[4px] cursor-pointer flex items-center justify-center p-2"
            >
              <.svg
                type="toggle_up"
                class={"w-[12px] h-[12px] transition-all ease-in-out delay-150 duration-300 #{if @closed, do: "rotate-180", else: ""}"}
              />
            </div>
          </div>

          <div :if={!@published} class="w-[16px] h-[16px] mr-[12px] ml-[8px] my-[4px] cursor-move">
            <.icon name="hero-arrows-pointing-out" class="hero-arrow" />
          </div>
        </div>
      </div>
      <div class={" grid #{if @closed, do: "grid-rows-[0fr]", else: "grid-rows-[1fr]"} transition-all ease-in-out delay-150 duration-300"}>
        <ul class="grid gap-2 overflow-hidden">
          <li class="px-[12px] py-[12px]">
            {render_slot(@inner_block)}
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
