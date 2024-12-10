defmodule GlorioCmsWeb.Components.HelperComponents.RootComponent do
  @moduledoc """
  A default component base
  """
  defmacro __using__(opts) do
    title = Keyword.fetch!(opts, :title)
    icon_type = Keyword.fetch!(opts, :icon_type)
    category = Keyword.fetch!(opts, :category)
    description = Keyword.fetch!(opts, :description)
    preview_module = Keyword.fetch!(opts, :preview_module)
    version = Keyword.fetch!(opts, :version)

    quote bind_quoted: [
            title: title,
            icon_type: icon_type,
            description: description,
            category_name: category,
            preview_module: preview_module,
            version: version
          ] do
      import GlorioCmsWeb.Components.HelperComponents.DrawerComponents

      def title(), do: unquote(title)

      def category(), do: unquote(category_name)

      def description(), do: unquote(description)

      def icon_type(), do: unquote(icon_type)

      def preview_module(), do: unquote(preview_module)

      def version(), do: unquote(version)

      def render_draweritem(var!(assigns)) do
        ~H"""
        <.drawer_preview
          {assigns}
          description={@component.description()}
          icon_type={@component.icon_type()}
          title={@component.title()}
        />
        """
      end

      def render_preview(var!(assigns)) do
        ~H"""
        <div>
          <.live_component module={@component.preview_module()} id={@block.id} {assigns} />
        </div>
        """
      end

      def serialize(_api_version, block) do
        %{
          id: block.id,
          component_type: block.component_type,
          properties: block.properties
        }
      end
    end
  end
end
