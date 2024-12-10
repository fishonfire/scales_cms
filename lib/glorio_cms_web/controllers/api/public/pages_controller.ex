defmodule GlorioCmsWeb.Api.Public.PagesController do
  use GlorioCmsWeb, :controller

  alias GlorioCms.Cms.CmsPageLocaleLatestVariants

  def show(conn, %{"id" => id} = params) do
    pv =
      CmsPageLocaleLatestVariants.get_cms_page_locale_latest_variant_for_page_and_locale(
        id,
        locale(params)
      )
      |> CmsPageLocaleLatestVariants.preload_page_variant()

    conn
    |> render(
      :show,
      page: pv.latest_published_page,
      api_version: conn.assigns.api_version
    )
  end

  def locale(%{"locale" => locale}), do: locale
  def locale(_), do: GlorioCms.Cms.Helpers.Locales.default_locale()
end
