defmodule ScalesCmsWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use ScalesCmsWeb, :controller` and
  `use ScalesCmsWeb, :live_view`.
  """
  use ScalesCmsWeb, :html

  embed_templates "layouts/*"

  defp has_custom_assets(), do: assets_config()[:enabled]

  defp custom_asset_path(asset) when asset in [:css, :js] do
    Phoenix.VerifiedRoutes.static_path(
      endpoint(),
      asset_filename(asset)
    )
  end

  defp cms_asset_path(conn, asset) when asset in [:css, :js] do
    hash = ScalesCmsWeb.Plugs.Assets.current_hash(asset)

    prefix = "/cms"

    Phoenix.VerifiedRoutes.unverified_path(
      conn,
      conn.private.phoenix_router,
      "#{prefix}/#{asset}-#{hash}"
    )
  end

  defp asset_filename(:css), do: "/#{assets_prefix()}/#{assets_config()[:css_file]}"

  defp asset_filename(:js), do: "/#{assets_prefix()}/#{assets_config()[:js_file]}"

  defp assets_prefix(), do: assets_config()[:prefix]

  defp assets_config() do
    Application.get_env(:scales_cms, :custom_assets,
      enabled: false,
      css_file: "app.css",
      js_file: "app.js",
      prefix: "assets"
    )
  end

  defp endpoint(), do: Application.get_env(:scales_cms, :endpoint)
end
