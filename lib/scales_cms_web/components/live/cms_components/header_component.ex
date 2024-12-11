defmodule ScalesCmsWeb.Components.CmsComponents.Header do
  @moduledoc """
  A header component for the CMS
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper

  defmodule HeaderPreview do
    @moduledoc false
    use ScalesCmsWeb, :live_component

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

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: "Header",
    category: "Content",
    description: "A nice header",
    icon_type: "cms_rich_text",
    preview_module: HeaderPreview,
    version: "0.0.1"
end
