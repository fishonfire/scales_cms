defmodule ScalesCmsWeb.Components.CmsComponentsRenderer do
  @moduledoc """
  The renderer of all the blocks, linking them to the right components
  """
  use ScalesCmsWeb, :live_component

  attr :id, :string, required: true
  attr :published, :boolean, default: false
  attr :deleting, :boolean, default: false
  attr :animate_in, :boolean, default: false
  attr :ghost_height, :float, default: 0.0
  attr :locale, :string, required: true
  attr :block, ScalesCms.Cms.CmsPageVariantBlock
  attr :template_builder, :boolean, default: false

  def render_preview(assigns) do
    case ScalesCms.Helpers.BlockResolver.resolve_block(assigns.block, assigns.locale) do
      {:ok, resolved_block} ->
        component =
          ScalesCmsWeb.Components.CmsComponents.get_component(resolved_block.component_type)

        assigns =
          assigns
          |> assign(:block, resolved_block)
          |> assign(:component, component)
          |> assign(
            :disabled,
            assigns.published ||
              (ScalesCms.Helpers.BlockResolver.template_block?(assigns.block) &&
                 !assigns.template_builder)
          )

        ~H"""
        <div
          id={@id}
          data-id={@block.id}
          phx-hook="CMSComponentAnimator"
          data-animate-in={@animate_in}
          data-ghost-height={@ghost_height}
          class={[
            "draggable border border-slate-200 mb-8 rounded bg-white overflow-hidden",
            if(@deleting, do: "deleting", else: "")
          ]}
        >
          <%= if @component do %>
            {@component.render_preview(assigns)}
          <% else %>
            <p>ID: {@block.id}</p>
            <p>Type: {@block.component_type}</p>
            <p>Sort order: {@block.sort_order}</p>
          <% end %>
        </div>
        """

      {:error, :template_not_found} ->
        ~H"""
        <div class="border border-red-300 bg-red-50 p-4 rounded">
          Missing template for block #{@block.id}
        </div>
        """
    end
  end
end
