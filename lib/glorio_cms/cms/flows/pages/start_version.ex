defmodule GlorioCms.Cms.Flows.Pages.StartVersion do
  @moduledoc """
  Starts a new version based on a give page variant. It copies then
  relevant parameters, and duplicates all blocks.
  """

  alias GlorioCms.Cms.CmsPageVariant
  alias GlorioCms.Cms.CmsPageVariants
  alias GlorioCms.Cms.CmsPageVariantBlocks
  alias GlorioCms.Cms.Flows.Pages.SetToVersion

  def perform(%CmsPageVariant{} = cms_page_variant) do
    with {:ok, new_cms_page_variant} <-
           CmsPageVariants.create_cms_page_variant(%{
             title: cms_page_variant.title,
             cms_page_id: cms_page_variant.cms_page_id,
             locale: cms_page_variant.locale,
             version: cms_page_variant.version + 1,
             published_at: nil
           }) do
      duplicate_blocks_for_page_variant(new_cms_page_variant, cms_page_variant)

      SetToVersion.perform(new_cms_page_variant)

      {:ok, new_cms_page_variant}
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
