defmodule GlorioCms.Cms.Flows.PublishingFlows do
  @moduledoc """
  A collections of flows to aid publishing
  """
  alias GlorioCms.Cms.CmsPageVariant
  alias GlorioCms.Cms.CmsPageVariants
  alias GlorioCms.Cms.CmsPageLocaleLatestVariants
  alias GlorioCms.Cms.CmsPageVariants
  alias GlorioCms.Cms.CmsPageVariantBlocks

  def publish(%CmsPageVariant{} = cms_page_variant) do
    set_to_latest_published(cms_page_variant)

    CmsPageVariants.update_cms_page_variant(
      cms_page_variant,
      %{
        published_at: DateTime.utc_now()
      }
    )
  end

  @doc """
  Starts a new version based on a give page variant. It copies then
  relevant parameters, and duplicates all blocks.
  """
  def start_new_version(%CmsPageVariant{} = cms_page_variant) do
    with {:ok, new_cms_page_variant} <-
           CmsPageVariants.create_cms_page_variant(%{
             title: cms_page_variant.title,
             cms_page_id: cms_page_variant.cms_page_id,
             locale: cms_page_variant.locale,
             version: cms_page_variant.version + 1,
             published_at: nil
           }) do
      duplicate_blocks_for_page_variant(new_cms_page_variant, cms_page_variant)

      set_to_latest(new_cms_page_variant)

      {:ok, new_cms_page_variant}
    end
  end

  def select_version_based_on_locale(%CmsPageVariant{} = cms_page_variant, locale) do
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

        set_to_latest(new_cms_page_variant)

        new_cms_page_variant

      new_cms_page_variant ->
        new_cms_page_variant
    end
  end

  defp set_to_latest(variant) do
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

  defp duplicate_blocks_for_page_variant(
         %CmsPageVariant{} = new_page_variant,
         %CmsPageVariant{} = old_page_variant
       ) do
    CmsPageVariantBlocks.list_blocks_for_page_variant(old_page_variant.id)
    |> Enum.each(fn block ->
      CmsPageVariantBlocks.create_cms_page_variant_block(%{
        sort_order: block.sort_order,
        component_type: block.component_type,
        properties: block.properties,
        cms_page_variant_id: new_page_variant.id
      })
    end)
  end
end
