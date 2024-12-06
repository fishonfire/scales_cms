defmodule GlorioCmsWeb.Components.CmsComponents.Md do
  @moduledoc """
  The markdown component, allowing the user to use a HTML WYSIWYG editor, transforming that HTML back to MD
  """
  use GlorioCmsWeb, :live_component

  import GlorioCmsWeb.Components.HelperComponents.DrawerComponents
  alias GlorioCmsWeb.Components.CmsComponents.Md.MdEditor

  def title(), do: "Markdown"

  def category(), do: "Content"

  def render_draweritem(assigns) do
    ~H"""
    <.drawer_preview
      icon_type="cms_rich_text"
      title="Markdown"
      description="Small or lang text like title or description"
    />
    """
  end

  def render_preview(assigns) do
    ~H"""
    <div>
      <.live_component module={MdEditor} id={assigns.block.id} {assigns} />
    </div>
    """
  end
end
