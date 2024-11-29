defmodule GlorioCmsWeb.Components.CmsComponents.Test do
  use GlorioCmsWeb, :live_component
  alias GlorioCmsWeb.Components.HelperComponents.BlockWrapper
  import GlorioCmsWeb.Components.HelperComponents.DrawerComponents

  def title(), do: "Test"

  defmodule HeaderPreview do
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

  def render_draweritem(assigns) do
    ~H"""
    <.drawer_preview icon_type="cms_rich_text" title="Test" description="A nice test" />
    """
  end

  def render_preview(assigns) do
    ~H"""
    <.live_component module={HeaderPreview} id={assigns.block.id} {assigns} />
    """
  end
end
