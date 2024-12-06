defmodule GlorioCms.Cms.Flows.Pages.SetToVersion do
  @moduledoc """
  Set a page variant to the latest version per locale. This provides the API of
  an easy way to find the latest version of a specific page
  """
  alias GlorioCms.Cms.CmsPageLocaleLatestVariants

  def perform(variant) do
    case CmsPageLocaleLatestVariants.get_cms_page_locale_latest_variant_for_page_and_locale(
           variant.cms_page_id,
           variant.locale
         ) do
      nil ->
        with {:ok, cplv} <-
               CmsPageLocaleLatestVariants.create_cms_page_locale_latest_variant(%{
                 cms_page_id: variant.cms_page_id,
                 locale: variant.locale,
                 cms_page_latest_variant_id: variant.id
               }),
             do: cplv

      cplv ->
        with {:ok, cplv} <-
               CmsPageLocaleLatestVariants.update_cms_page_locale_latest_variant(cplv, %{
                 cms_page_latest_variant_id: variant.id
               }),
             do: cplv
    end
  end
end
