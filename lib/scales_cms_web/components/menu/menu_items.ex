defmodule ScalesCmsWeb.Components.MenuItems do
  @moduledoc """
  The renderer and config for the menu items
  """
  import ScalesCmsWeb.Gettext
  use ScalesCmsWeb, :live_component

  @default_menu_items [
    %ScalesCmsWeb.Components.MenuItem{
      title: gettext("Dashboard"),
      icon: "hero-home",
      route: "/cms"
    },
    %ScalesCmsWeb.Components.MenuItem{
      title: gettext("Pages"),
      icon: "hero-document",
      route: "/cms/directories"
    },
    %ScalesCmsWeb.Components.MenuItem{
      title: gettext("Settings"),
      icon: "hero-wrench-screwdriver",
      route: "/cms/settings"
    }
  ]

  def menu_items() do
    @default_menu_items ++ configured_menu_items()
  end

  def configured_menu_items(), do: Application.get_env(:scales_cms, :menu_items, [])

  # TODO: Fix conditional class logic
  def render(assigns) do
    ~H"""
    <ul class="sidebar-menu">
      <li :for={menu_item <- menu_items()}>
        <.link
          patch={menu_item.route}
          class={"sidebar-menu-item #{if menu_item.route == assigns[:current_path], do: "active-item"}"}
        >
          <.icon name={menu_item.icon} />
          <span class="ms-2">{menu_item.title}</span>
        </.link>
      </li>
    </ul>
    """
  end
end
