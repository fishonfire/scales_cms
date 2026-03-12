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
      alternative_routes: ["/cms/page_builder/*", "/cms/directories/*", "/cms/pages/*"]
    },
    %ScalesCmsWeb.Components.MenuItem{
      title: gettext("Media Library"),
      icon: "hero-photo",
      route: "/cms/media"
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

  embed_templates "*.html"

  attr :sidebar_open, :boolean, default: true
  attr :current_uri, :any, required: true
  attr :menu_items, :list, required: true

  def menu_items_layout(assigns)

  def render(assigns) do
    assigns = assign(assigns, :menu_items, menu_items())

    ~H"""
    <.menu_items_layout
      sidebar_open={@sidebar_open}
      current_uri={@current_uri}
      menu_items={@menu_items}
    />
    """
  end
end
