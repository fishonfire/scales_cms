defmodule GlorioCms.Cms.Flows.Pages.SelectVersion do
  @moduledoc """
  Select the right version of a page variant based on the locale
  """
  alias GlorioCms.Cms.CmsPageVariant
  alias GlorioCms.Cms.CmsPageVariants
  alias GlorioCms.Cms.Flows.Pages.SetToVersion

  def perform(%CmsPageVariant{} = cms_page_variant, locale) do
    case CmsPageVariants.get_latest_cms_page_variant_for_locale(
           cms_page_variant.cms_page_id,
           locale
         ) do
      nil ->
        {:ok, new_cms_page_variant} =
          CmsPageVariants.create_cms_page_variant(%{
            cms_page_id: cms_page_variant.cms_page_id,
            locale: locale,
            version: 1,
            title: cms_page_variant.title
          })

        SetToVersion.perform(new_cms_page_variant)

        new_cms_page_variant

      new_cms_page_variant ->
        new_cms_page_variant
    end
  end
end
