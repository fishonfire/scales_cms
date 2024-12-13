# Setup new menu items
Each menu item in the left CMS menu can be configured, outside of the default Home & Pages.

Menu items can be added by configuring ScalesCMS with the following config;

```elixir
config :scales_cms,
  menu_items: CmsDemoWeb.MenuItems.get_menu_items()
```

Where the `menu_items.ex` would be set up as following;

```elixir
defmodule CmsDemoWeb.MenuItems do
  @menu_items [
    %ScalesCmsWeb.Components.MenuItem{
      title: gettext("My own page"), # the title shown in the menu
      icon: "hero-home", # a hero icon to represent your item
      route: "/a route" # starts with a slash, e.g. "/my-own-page"
    }
  ]

  def get_menu_items(), do: @menu_items
end
```
