defmodule GlorioCmsWeb.CmsPageLive.Show do
  use GlorioCmsWeb, :live_view

  alias GlorioCms.Cms.CmsPages
  alias GlorioCms.Cms.CmsPageVariants

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    default_locale =
      Application.get_env(:glorio_cms, :cms)[:default_locale] || "en-US"

    case CmsPageVariants.get_latest_cms_page_variant_for_locale(
           id,
           default_locale
         ) do
      nil ->
        with page <- CmsPages.get_cms_page!(id),
             {:ok, pv} <-
               CmsPageVariants.create_cms_page_variant(%{
                 cms_page_id: id,
                 locale: default_locale,
                 title: page.title,
                 version: 1
               }) do
          socket
          |> push_navigate(to: ~p"/cms/cms_page_builder/#{pv.id}")
          |> then(&{:noreply, &1})
        end

      pv ->
        socket
        |> push_navigate(to: ~p"/cms/cms_page_builder/#{pv.id}")
        |> then(&{:noreply, &1})
    end
  end
end
