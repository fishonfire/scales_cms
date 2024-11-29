defmodule GlorioCmsWeb.Components.CmsComponents.Header do
  use GlorioCmsWeb, :live_component

  alias GlorioCmsWeb.Components.HelperComponents.BlockWrapper
  def title(), do: "Header"

  defmodule HeaderPreview do
    use GlorioCmsWeb, :live_component

    def render(assigns) do
      ~H"""
      <div>
        <.live_component id={"head-#{@block.id}"} module={BlockWrapper} type={@block.component_type}>
          Header
        </.live_component>
      </div>
      """
    end
  end

  def render_draweritem(assigns) do
    ~H"""
    <div><%= @type %></div>
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
