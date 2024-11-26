defmodule GlorioCmsWeb.Components.CmsComponents.Test do
  use GlorioCmsWeb, :live_component

  def title(), do: "Test"

  defmodule HeaderPreview do
    use GlorioCmsWeb, :live_component

    def render(assigns) do
      ~H"""
      <div>
        Test
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
