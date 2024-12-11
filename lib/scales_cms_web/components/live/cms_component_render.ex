defmodule ScalesCmsWeb.Components.CmsComponentsRenderer do
  @moduledoc """
  The renderer of all the blocks, linking them to the right components
  """
  use ScalesCmsWeb, :live_component

  attr :id, :string, required: true
  attr :published, :boolean, required: true
  attr :block, ScalesCms.Cms.CmsPageVariantBlock

  def render_preview(assigns) do
    assigns =
      assign(
        assigns,
        :component,
        ScalesCmsWeb.Components.CmsComponents.get_component(assigns.block.component_type)
      )

    ~H"""
    <div
      id={@id}
      data-id={@block.id}
      class="draggable border-[1px] mb-8 rounded-xl bg-white overflow-hidden"
    >
      <%= if @component do %>
        {@component.render_preview(assigns)}
      <% else %>
        <!-- Component not found -->
        <p>ID: {@block.id}</p>
        <p>Type: {@block.component_type}</p>
        <p>Sort order: {@block.sort_order}</p>
      <% end %>
    </div>
    """
  end
end
