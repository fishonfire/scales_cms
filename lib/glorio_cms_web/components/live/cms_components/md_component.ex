defmodule GlorioCmsWeb.Components.CmsComponents.Md do
  use GlorioCmsWeb, :live_component

  alias GlorioCmsWeb.Components.HelperComponents.BlockWrapper
  def title(), do: "Header"

  defmodule HeaderPreview do
    use GlorioCmsWeb, :live_component

    def render(assigns) do
      ~H"""
      <div>
        <.live_component id={"head-#{@block.id}"} module={BlockWrapper} type={@block.component_type}>
          <div id={"markdown-#{@block.id}"} phx-hook="Markdown" phx-target={@myself}>
            <div type="text" id={"markdown-#{@block.id}-editor"} class="wysiwyg" phx-update="ignore" />
          </div>

          <input
            type="hidden"
            id={"markdown-#{@block.id}-content"}
            phx-change="change-content"
            phx-target={@myself}
          />
        </.live_component>
      </div>
      """
    end
  end

  def render_draweritem(assigns) do
    ~H"""
    <div class="flex flex-row">
      <div class="icon mr-4">
        <.svg type="cms_rich_text" class="w-[24px] h-[24px]" />
      </div>

      <div class="grow">
        <p><%= @type %></p>
        <p>Small or lang text like title or description</p>
      </div>

      <div class="drag-handle">
        <.svg type="drag_handle" class="w-[24px] h-[24px]" />
      </div>
    </div>
    """
  end

  def render_preview(assigns) do
    ~H"""
    <div>
      <.live_component module={HeaderPreview} id={assigns.block.id} {assigns} />
    </div>
    """
  end
end
