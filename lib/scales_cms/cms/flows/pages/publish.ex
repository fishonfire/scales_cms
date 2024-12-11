defmodule ScalesCms.Cms.Flows.Pages.Publish do
  @moduledoc """
  A collections of flows to aid publishing
  """
  alias ScalesCms.Cms.CmsPageVariant
  alias ScalesCms.Cms.CmsPageVariants
  alias ScalesCms.Cms.CmsPageLocaleLatestVariants
  alias ScalesCms.Cms.CmsPageVariants

  def perform(%CmsPageVariant{} = cms_page_variant) do
    set_to_latest_published(cms_page_variant)

    CmsPageVariants.update_cms_page_variant(
      cms_page_variant,
      %{
        published_at: DateTime.utc_now()
      }
    )
  end

  defp set_to_latest_published(variant) do
    latest_variant =
      CmsPageVariants.get_latest_cms_page_variant_for_locale(
        variant.cms_page_id,
        variant.locale
      )

    latest_variant_id = if latest_variant != nil, do: latest_variant.id, else: nil

    case CmsPageLocaleLatestVariants.get_cms_page_locale_latest_variant_for_page_and_locale(
           variant.cms_page_id,
           variant.locale
         ) do
      nil ->
        with {:ok, cplv} <-
               CmsPageLocaleLatestVariants.create_cms_page_locale_latest_variant(%{
                 cms_page_id: variant.cms_page_id,
                 locale: variant.locale,
                 cms_page_latest_published_variant_id: variant.id,
                 cms_page_latest_variant_id: latest_variant_id
               }),
             do: cplv

      cplv ->
        with {:ok, cplv} <-
               CmsPageLocaleLatestVariants.update_cms_page_locale_latest_variant(cplv, %{
                 cms_page_latest_published_variant_id: variant.id
               }),
             do: cplv
    end
  end
end
