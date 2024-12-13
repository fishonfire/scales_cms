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
    }
  ]

  def menu_items() do
    @default_menu_items ++ configured_menu_items()
  end

  def configured_menu_items(), do: Application.get_env(:scales_cms, :menu_items, [])

  def render(assigns) do
    ~H"""
    <ul class="space-y-2 font-medium p-4">
      <li :for={menu_item <- menu_items()}>
        <.link
          patch={menu_item.route}
          class="flex items-center p-2 text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-primary "
        >
          <.icon name={menu_item.icon} />
          <span class="ms-3">{menu_item.title}</span>
        </.link>
      </li>
    </ul>
    """
  end
end
