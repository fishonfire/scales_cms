defmodule GlorioCmsWeb.Components.CmsComponentsRenderer do
  use GlorioCmsWeb, :live_component

  attr :id, :string, required: true
  attr :block, GlorioCms.Cms.CmsPageVariantBlock

  def render_preview(assigns) do
    assigns =
      assign(
        assigns,
        :component,
        GlorioCmsWeb.Components.CmsComponents.get_component(assigns.block.component_type)
      )

    ~H"""
    <div id={@id} data-id={@block.id} class="p-4 border-2 mb-4 draggable" draggable="true">
      <%= if @component do %>
        <%= @component.render_preview(assigns) %>
      <% else %>
        <!-- Component not found -->
        <p>ID: <%= @block.id %></p>
        <p>Type: <%= @block.component_type %></p>
        <p>Sort order: <%= @block.sort_order %></p>
      <% end %>
    </div>
    """
  end
end
