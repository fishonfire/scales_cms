defmodule ScalesCmsWeb.Components.DashboardTiles do
  @moduledoc """
  The renderer and config for the dashboard tiles.

  Tiles are configurable via application config, similar to menu items.
  Configure additional tiles in your config:

      config :scales_cms, :dashboard_tiles, [
        %ScalesCmsWeb.Components.DashboardTile{
          title: "Custom Tile",
          description: "Description here",
          icon: "hero-star",
          route: "/cms/custom"
        }
      ]
  """
  use ScalesCmsWeb, :live_component

  use Gettext,
    backend: ScalesCmsWeb.Gettext

  alias ScalesCmsWeb.Components.DashboardTile

  @default_tiles [
    %DashboardTile{
      title: gettext("Pages"),
      description: gettext("Manage your content pages and directories"),
      icon: "hero-document",
      route: "/cms/directories"
    },
    %DashboardTile{
      title: gettext("Media Library"),
      description: gettext("Upload and manage images, videos, and documents"),
      icon: "hero-photo",
      route: "/cms/media"
    },
    %DashboardTile{
      title: gettext("Settings"),
      description: gettext("Configure CMS settings"),
      icon: "hero-wrench-screwdriver",
      route: "/cms/settings"
    },

    # Should implement this dashboard tile only on project Landmacht
    %DashboardTile{
      title: gettext("Documentation"),
      description: gettext("Read the CMS handbook and guides"),
      icon: "hero-book-open",
      route:
        "https://docs.google.com/document/d/13SaI5-D5cV8QgobgiA5ZPDYEu8c0jz4G_R-QDvUcJxQ/edit?usp=sharing",
      external: true
    }
  ]

  def dashboard_tiles() do
    @default_tiles ++ configured_tiles()
  end

  def configured_tiles(), do: Application.get_env(:scales_cms, :dashboard_tiles, [])

  # Embeds tile_content from tile_content.html.heex
  # and dashboard_tile_grid from dashboard_tile_grid.html.heex
  embed_templates "*.html"

  attr :tile, :map, required: true
  def tile_content(assigns)

  attr :class, :string, default: nil
  attr :tiles, :list, required: true
  def dashboard_tile_layout(assigns)

  attr :class, :string, default: nil
  attr :tiles, :list, default: nil

  def render(assigns) do
    assigns = assign(assigns, :tiles, dashboard_tiles())

    ~H"""
    <.dashboard_tile_layout tiles={@tiles} class={@class} />
    """
  end
end
