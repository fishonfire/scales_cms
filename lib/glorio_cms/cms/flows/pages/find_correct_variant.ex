defmodule GlorioCms.Cms.Flows.Pages.FindCorrectVariant do
  @moduledoc """
  Find the correct page variant for a specific locale if this is missing.
  """
  alias GlorioCms.Cms.CmsPageVariants
  alias GlorioCms.Cms.CmsPages

  def perform(page_id, locale) do
    case CmsPageVariants.get_latest_cms_page_variant_for_locale(
           page_id,
           locale
         ) do
      nil ->
        with page <- CmsPages.get_cms_page!(page_id),
             {:ok, page_variant} <-
               CmsPageVariants.create_cms_page_variant(%{
                 cms_page_id: page_id,
                 locale: locale,
                 title: page.title,
                 version: 1
               }),
             do: page_variant

      page_variant ->
        page_variant
    end
  end
end
