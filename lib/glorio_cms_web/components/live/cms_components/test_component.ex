defmodule GlorioCmsWeb.Components.CmsComponents.Test do
  @moduledoc false
  use GlorioCmsWeb, :live_component
  alias GlorioCmsWeb.Components.HelperComponents.BlockWrapper
  import GlorioCmsWeb.Components.HelperComponents.DrawerComponents

  defmodule HeaderPreview do
    @moduledoc false

    use GlorioCmsWeb, :live_component

    def render(assigns) do
      ~H"""
      <div>
        <.live_component id={"head-#{@block.id}"} module={BlockWrapper} block={@block}>
          Test
        </.live_component>
      </div>
      """
    end
  end

  use GlorioCmsWeb.Components.HelperComponents.RootComponent,
    title: "Test",
    category: "Content",
    description: "A test",
    icon_type: "cms_rich_text",
    preview_module: HeaderPreview,
    version: "0.0.1"
end
