defmodule GlorioCmsWeb.Components.CmsComponents.Header do
  @moduledoc """
  A header component for the CMS
  """
  use GlorioCmsWeb, :live_component

  alias GlorioCmsWeb.Components.HelperComponents.BlockWrapper

  defmodule HeaderPreview do
    @moduledoc false
    use GlorioCmsWeb, :live_component

    def render(assigns) do
      ~H"""
      <div>
        <.live_component id={"head-#{@block.id}"} module={BlockWrapper} block={@block}>
          Header
        </.live_component>
      </div>
      """
    end
  end

  use GlorioCmsWeb.Components.HelperComponents.RootComponent,
    title: "Header",
    category: "Content",
    description: "A nice header",
    icon_type: "cms_rich_text",
    preview_module: HeaderPreview
end
