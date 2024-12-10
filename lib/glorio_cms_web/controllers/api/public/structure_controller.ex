defmodule GlorioCmsWeb.Api.Public.StructureController do
  use GlorioCmsWeb, :controller
  alias GlorioCms.Cms.CmsPageLocaleLatestVariants
  alias GlorioCms.Cms.CmsDirectories

  def index(conn, params) do
    pages =
      CmsPageLocaleLatestVariants.list_cms_page_locale_latest_variants_for_locale(locale(params))
      |> CmsPageLocaleLatestVariants.preload_page_variants()

    directories =
      CmsDirectories.list_all_active_cms_directories()

    conn
    |> render(:index,
      pages: pages,
      directories: directories,
      api_version: conn.assigns.api_version
    )
  end

  def locale(%{"locale" => locale}), do: locale
  def locale(_), do: GlorioCms.Cms.Helpers.Locales.default_locale()
end
