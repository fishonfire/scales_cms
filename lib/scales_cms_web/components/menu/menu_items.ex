defmodule ScalesCmsWeb.Components.MenuItems do
  @moduledoc """
  The renderer and config for the menu items
  """
  use ScalesCmsWeb, :live_component

  use Gettext,
    backend: ScalesCmsWeb.Gettext

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
      icon: "hero-cog-8-tooth",
      route: "/cms/settings"
    }
  ]

  def menu_items() do
    @default_menu_items ++ configured_menu_items()
  end

  def configured_menu_items(), do: Application.get_env(:scales_cms, :menu_items, [])
end
