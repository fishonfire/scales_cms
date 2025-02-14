defmodule ScalesCmsWeb.CmsComponents do
  @moduledoc """
  A collection of components for the CMS
  """

  use Phoenix.Component

  use Gettext,
    backend: ScalesCmsWeb.Gettext

  import ScalesCmsWeb.CoreComponents, only: [icon: 1]

  alias ScalesCmsWeb.Components.MenuItems

  attr :back_patch, :any, default: nil
  attr :title, :string
  slot :actions, doc: "the slot for page actions, such as a submit button"
  slot :inner_block, required: true

  def sub_menu(assigns) do
    ~H"""
    <div class="sub-menu">
      <.link :if={@back_patch} patch={@back_patch} class="back-link">
        <div class="icon">
          <.icon name="hero-arrow-left" />
        </div>
        <div class="">
          {gettext("Back")}
        </div>
      </.link>

      <div class="content-slot">
        {render_slot(@inner_block)}
      </div>

      <div class="actions">
        {render_slot(@actions)}
      </div>
    </div>
    """
  end

  def main_menu(assigns) do
    ~H"""
    <ul class="menu">
      <li :for={menu_item <- MenuItems.menu_items()} class="menu-item">
        <.link patch={menu_item.route}>
          <.icon name={menu_item.icon} />

          <div class="menu-title">
            {menu_item.title}
          </div>
        </.link>
      </li>
    </ul>
    """
  end
end
