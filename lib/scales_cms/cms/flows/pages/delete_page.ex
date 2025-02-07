defmodule ScalesCms.Cms.Flows.Pages.DeletePage do
  @moduledoc """
  Deletes a page including its descendants.
  """
  alias ScalesCms.Cms.{
    CmsPages,
    CmsPageVariants,
    CmsPageVariantBlocks,
    CmsPageLocaleLatestVariants
  }

  def perform(id) do
    cms_page = CmsPages.get_cms_page!(id)

    ids = CmsPageVariants.list_ids_for_page(id)

    CmsPageLocaleLatestVariants.delete_cms_page_locale_latest_variants_for_page(id)
    CmsPageVariantBlocks.delete_blocks_for_cms_page_variants(ids)
    CmsPageVariants.delete_cms_page_variants(ids)

    {:ok, _} = CmsPages.delete_cms_page(cms_page)
  end
end
