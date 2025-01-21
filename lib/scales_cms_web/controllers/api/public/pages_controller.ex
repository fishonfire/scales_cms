defmodule ScalesCmsWeb.Api.Public.PagesController do
  use ScalesCmsWeb, :controller

  alias ScalesCms.Cms.CmsPageLocaleLatestVariants

  def index(conn, params) do
    current_page = String.to_integer(Map.get(params, "current_page", "1"))
    page_size = String.to_integer(Map.get(params, "page_size", "30"))

    pages =
      CmsPageLocaleLatestVariants.list_paginated_cms_page_locale_latest_variants_for_locale(
        locale(params),
        current_page,
        page_size
      )
      |> CmsPageLocaleLatestVariants.preload_page_variants()

    total_count =
      CmsPageLocaleLatestVariants.count_cms_page_locale_latest_variants_for_locale(locale(params))

    conn
    |> render(
      :index,
      pages: pages,
      pagination: %{
        current_page: current_page,
        page_size: page_size,
        total_count: total_count,
        total_pages: div(total_count, page_size)
      },
      api_version: conn.assigns.api_version
    )
  end

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

  def show(conn, %{"slug" => slug} = params) do
    pv =
      CmsPageLocaleLatestVariants.get_cms_page_locale_latest_variant_for_page_and_locale_by_slug(
        slug,
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
  def locale(_), do: ScalesCms.Cms.Helpers.Locales.default_locale()
end
