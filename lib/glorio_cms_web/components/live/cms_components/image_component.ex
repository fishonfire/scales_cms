defmodule GlorioCmsWeb.Components.CmsComponents.Image do
  @moduledoc """
  An upload to s3 image component
  """
  use GlorioCmsWeb, :live_component

  import GlorioCmsWeb.Components.HelperComponents.DrawerComponents

  alias GlorioCmsWeb.Components.CmsComponents.Image.ImageEditor

  def title(), do: "Image"

  def category(), do: "Image"

  def render_draweritem(assigns) do
    ~H"""
    <.drawer_preview icon_type="cms_rich_text" title="Image" description="An image!" />
    """
  end

  def render_preview(assigns) do
    ~H"""
    <div>
      <.live_component module={ImageEditor} id={assigns.block.id} {assigns} />
    </div>
    """
  end
end
