defmodule ScalesCmsWeb.Components.CmsComponents.Test do
  @moduledoc false
  use ScalesCmsWeb, :live_component
  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper
  import ScalesCmsWeb.Components.HelperComponents.DrawerComponents

  defmodule HeaderPreview do
    @moduledoc false

    use ScalesCmsWeb, :live_component

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

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: "Test",
    category: "Content",
    description: "A test",
    icon_type: "cms_rich_text",
    preview_module: HeaderPreview,
    version: "0.0.1"
end
