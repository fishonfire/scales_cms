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

  attr :class, :string, default: nil

  def render(assigns) do
    assigns = assign(assigns, :tiles, dashboard_tiles())

    ~H"""
    <div class={["grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6", @class]}>
      <%= for tile <- @tiles do %>
        <%= if tile.external do %>
          <a
            href={tile.route}
            target="_blank"
            rel="noopener noreferrer"
            class="group block p-6 bg-white dark:bg-gray-800 rounded-lg shadow-sm hover:shadow-md transition-all duration-200 border border-gray-200 dark:border-gray-700"
          >
            <.tile_content tile={tile} />
          </a>
        <% else %>
          <.link
            patch={tile.route}
            class="group block p-6 bg-white dark:bg-gray-800 rounded-lg shadow-sm hover:shadow-md transition-all duration-200 border border-gray-200 dark:border-gray-700"
          >
            <.tile_content tile={tile} />
          </.link>
        <% end %>
      <% end %>
    </div>
    """
  end

  attr :tile, :map, required: true

  defp tile_content(assigns) do
    ~H"""
    <div class="flex items-start space-x-4">
      <div class="flex-shrink-0 p-3 rounded-lg transition-colors">
        <.icon name={@tile.icon} class="h-6 w-6" />
      </div>
      <div class="flex-1 min-w-0">
        <h3 class="text-lg font-semibold text-gray-900 dark:text-white transition-colors">
          {@tile.title}
          <.icon
            :if={@tile.external}
            name="hero-arrow-top-right-on-square"
            class="inline-block h-4 w-4 ml-1 opacity-50"
          />
        </h3>
        <p :if={@tile.description} class="mt-1 text-sm text-gray-500 dark:text-gray-400">
          {@tile.description}
        </p>
      </div>
      <div class="flex-shrink-0 opacity-0 group-hover:opacity-100 transition-opacity">
        <.icon name="hero-arrow-right" class="h-5 w-5" />
      </div>
    </div>
    """
  end
end
