defmodule ScalesCmsWeb.Components.MenuItems do
  @moduledoc """
  The renderer and config for the menu items.

  When the sidebar is open, shows icon + title in the normal layout.
  When the sidebar is closed, shows only the icon justified to the end (right side)
  so it remains visible in the collapsed sidebar strip.
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
      route: "/cms/directories",
      alternative_routes: ["/cms/page_builder/*"]
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

  def active_class(current_uri, menu_item),
    do: if(active_route?(current_uri, menu_item), do: "active", else: nil)

  defp active_route?(current_uri, %{route: route, alternative_routes: alt_routes}) do
    match_pattern?(current_uri, route) ||
      Enum.any?(alt_routes || [], &match_pattern?(current_uri, &1))
  end

  # Exact match only (no wildcard)
  defp match_pattern?(current_uri, pattern) when is_binary(pattern) do
    case String.ends_with?(pattern, "/*") do
      true ->
        prefix = String.trim_trailing(pattern, "/*")
        current_uri == prefix || String.starts_with?(current_uri, prefix <> "/")

      false ->
        current_uri == pattern
    end
  end

  attr :sidebar_open, :boolean, default: true
  attr :current_uri, :any, required: true

  def render(assigns) do
    ~H"""
    <ul class="sidebar-menu">
      <li :for={menu_item <- menu_items()}>
        <.link
          patch={menu_item.route}
          class={[
            "sidebar-menu-item",
            !@sidebar_open && "sidebar-menu-item-closed",
            active_class(@current_uri, menu_item)
          ]}
          title={if !@sidebar_open, do: menu_item.title, else: nil}
        >
          <span class={[
            "sidebar-menu-icon-left",
            "transition-opacity duration-300 ease-in-out",
            !@sidebar_open && "opacity-0 w-0 overflow-hidden"
          ]}>
            <.icon name={menu_item.icon} />
          </span>

          <span class={[
            "sidebar-menu-title ms-2",
            "transition-all duration-300 ease-in-out",
            !@sidebar_open && "opacity-0 w-0 overflow-hidden whitespace-nowrap"
          ]}>
            {menu_item.title}
          </span>

          <span class="flex-grow"></span>

          <span class={[
            "sidebar-menu-icon-right",
            "transition-opacity duration-300 ease-in-out",
            @sidebar_open && "opacity-0 w-0 overflow-hidden",
            !@sidebar_open && "opacity-100"
          ]}>
            <.icon name={menu_item.icon} />
          </span>
        </.link>
      </li>
    </ul>
    """
  end
end
