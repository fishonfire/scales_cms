defmodule GlorioCmsWeb.Components.CmsComponents.Header do
  use GlorioCmsWeb, :live_component

  def title(), do: "Header"

  defmodule HeaderPreview do
    use GlorioCmsWeb, :live_component

    def render(assigns) do
      ~H"""
      <div>
        Header
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
    <.live_component module={HeaderPreview} id={assigns.block.id} assigns={assigns} />
    """
  end
end
