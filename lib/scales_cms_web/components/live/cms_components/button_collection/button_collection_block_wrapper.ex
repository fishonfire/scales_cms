defmodule ScalesCmsWeb.Components.CmsComponents.ButtonCollection.ButtonCollectionWrapper do
  @moduledoc """
  The wrapper that goes around a block that is rendered in the WYSIWYG editor
  """
  use ScalesCmsWeb, :live_component

  @impl true
  def mount(socket) do
    socket
    |> assign(:closed, true)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("toggle-open", _, %{assigns: %{closed: closed}} = socket) do
    {:noreply, assign(socket, :closed, !closed)}
  end

  slot :inner_block, required: true
  attr :block, ScalesCms.Cms.CmsPageVariantBlock

  def render(assigns) do
    ~H"""
    <div>
      <div class="w-full flex justify-between bg-lightGrey py-[8px] mb-[4px] transition-all ease-in-out delay-150 duration-300">
        <div class="ml-[12px] text-sm	font-bold leading-[32px]">
          {@title}
        </div>
        <div class="flex">
          <div class="mr-[8px] bg-white rounded-lg flex">
            <div
              phx-click="delete_embedded"
              phx-value-id={@block.id}
              phx-value-embedded_field="buttons"
              phx-value-embedded_index={@embedded_index}
              class="mx-[8px] pr-[4px] py-[4px] border-r-2 cursor-pointer"
            >
              <.icon name="hero-trash" />
            </div>
            <div
              phx-click="toggle-open"
              phx-target={@myself}
              class="w-[24px] h-[24px] mx-[8px] py-[4px] cursor-pointer"
            >
              <.svg
                type="toggle_up"
                class={"w-[16px] h-[16px] mt-[6px] transition-all ease-in-out delay-150 duration-300 #{if @closed, do: "rotate-180", else: ""}"}
              />
            </div>
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
