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

## Rendering a page in the CMS layout
To render a page in the CMS layout you need to adapt your projects Web module.

```elixir
defmodule CmsDemoWeb do
  # <..>
  def cms_live_view do
    quote do
      use Phoenix.LiveView,
        layout: {ScalesCmsWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end
  # <..>
end
```

After setting it up your LiveView you than configure it to use cms_live_view instead of live_view,

as follows:

```elixir
defmodule CmsDemoWeb.YourAdminLive.Index do
  use CmsDemoWeb, :cms_live_view

  def render(assigns) do
    ~L"""
    <h1>My own page</h1>
    """
  end
end
```
