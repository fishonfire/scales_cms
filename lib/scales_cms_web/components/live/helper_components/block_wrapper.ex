defmodule ScalesCmsWeb.Components.HelperComponents.BlockWrapper do
  @moduledoc """
  The wrapper that goes around a block that is rendered in the WYSIWYG editor
  """
  use ScalesCmsWeb, :live_component
  alias ScalesCmsWeb.Helpers.TemplateMode

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
  def render(%{block: %ScalesCms.Cms.CmsBlockTemplate{}} = assigns) do
    ~H"""
    <div class="block-wrapper">
      <div class="w-full flex justify-between align-center bg-lightGrey py-[8px] transition-all ease-in-out delay-150 duration-300 ">
        <div class="align-middle ml-[12px] text-sm font-semibold leading-[32px]">
          {@component.title()}
          <span
            title={TemplateMode.label(@block.template_mode)}
            class={[
              "inline-block h-2 w-2 rounded-full",
              TemplateMode.dot_class(@block.template_mode)
            ]}
          />
        </div>
        <div class="flex gap-[8px] items-center">
          <div class="loading-indicator w-[24px] h-[24px] items-center justify-center flex">
            <.svg type="spinner" width="24" height="24" />
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

  def render(assigns) do
    ~H"""
    <div class="block-wrapper">
      <div class={"#{if !@published, do: "drag-handle"} cursor-move w-full flex justify-between align-center bg-lightGrey py-[8px] transition-all ease-in-out delay-150 duration-300 "}>
        <div class="align-middle ml-[12px] text-sm font-semibold leading-[32px]">
          {@component.title()}
          <span
            title={TemplateMode.label(@block.block_template_mode)}
            class={[
              "inline-block h-2 w-2 rounded-full",
              TemplateMode.dot_class(@block.block_template_mode)
            ]}
          />
        </div>
        <div class="flex gap-[8px] items-center">
          <div class="loading-indicator w-[24px] h-[24px] items-center justify-center flex">
            <.svg type="spinner" width="24" height="24" />
          </div>
          <div class="action-buttons bg-white rounded flex">
            <div
              :if={!@published && @block.block_template_mode in [:live, :snapshot]}
              phx-click={
                JS.dispatch("ultra-confirm",
                  detail: %{
                    message:
                      gettext("Detach this template from the page so you can customize it here?")
                  }
                )
              }
              phx-ultra-confirm-ok={JS.push("detach-template")}
              phx-value-id={@block.id}
              class="py-[8px] border-r-2 cursor-pointer flex items-center justify-center p-2"
              title={gettext("Detach template")}
            >
              <.icon name="hero-link-slash" class="icon-small" />
            </div>
            <div
              :if={
                !@published && @block.block_template_mode == :detached &&
                  !is_nil(@block.block_template_family_id)
              }
              phx-click={
                JS.dispatch("ultra-confirm",
                  detail: %{
                    message:
                      gettext(
                        "Reattach this block to its template? This will discard the custom page changes."
                      )
                  }
                )
              }
              phx-ultra-confirm-ok={JS.push("reattach-template")}
              phx-value-id={@block.id}
              class="py-[8px] border-r-2 cursor-pointer flex items-center justify-center p-2"
              title={gettext("Reattach template")}
            >
              <.icon name="hero-link" class="icon-small" />
            </div>
            <div
              :if={!@published}
              phx-click={
                JS.dispatch("ultra-confirm",
                  detail: %{
                    message:
                      gettext("Are you sure you want to delete %{title}?", title: @component.title)
                  }
                )
              }
              phx-ultra-confirm-ok={JS.push("delete")}
              phx-value-id={@block.id}
              class="py-[8px] border-r-2 cursor-pointer flex items-center justify-center p-2"
            >
              <.icon name="hero-trash" class="icon-small" />
            </div>
            <div
              phx-click="toggle-open"
              phx-target={@myself}
              class="py-[8px] cursor-pointer flex items-center justify-center p-2"
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
