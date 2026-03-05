defmodule ScalesCmsWeb.Components.DashboardTile do
  @moduledoc """
  A struct representing a configurable dashboard tile.

  ## Fields

    * `:title` - The title displayed on the tile (required)
    * `:description` - A brief description shown below the title (optional)
    * `:icon` - The hero icon name to display (required)
    * `:route` - The route to navigate to when clicked (required)
    * `:color` - The color theme for the tile, defaults to "blue" (optional)
      Supported colors: "blue", "green", "purple", "orange", "red", "gray"
    * `:external` - Whether the link is external (opens in new tab), defaults to false (optional)

  ## Example

      %ScalesCmsWeb.Components.DashboardTile{
        title: "Documentation",
        description: "Read the CMS handbook",
        icon: "hero-book-open",
        route: "https://docs.example.com",
        color: "blue",
        external: true
      }
  """

  @enforce_keys [:title, :icon, :route]
  defstruct [:title, :description, :icon, :route, color: "blue", external: false]

  @type t :: %__MODULE__{
          title: String.t(),
          description: String.t() | nil,
          icon: String.t(),
          route: String.t(),
          color: String.t(),
          external: boolean()
        }
end
