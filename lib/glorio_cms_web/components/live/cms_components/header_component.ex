defmodule GlorioCmsWeb.Components.CmsComponents.Header do
  use GlorioCmsWeb, :live_component

  alias GlorioCmsWeb.Components.HelperComponents.BlockWrapper
  import GlorioCmsWeb.Components.HelperComponents.DrawerComponents

  def title(), do: "Header"

  def category(), do: "Content"

  defmodule HeaderPreview do
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

  def render_draweritem(assigns) do
    ~H"""
    <.drawer_preview icon_type="cms_rich_text" title="Header" description="A nice header" />
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
