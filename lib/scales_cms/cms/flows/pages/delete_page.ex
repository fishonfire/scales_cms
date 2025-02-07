defmodule ScalesCms.Cms.Flows.Pages.DeletePage do
  @moduledoc """
  Deletes a page including its descendants.
  """
  alias ScalesCms.Cms.{CmsPages, CmsPageVariants, CmsPageVariantBlocks}

  def perform(id) do
    cms_page = CmsPages.get_cms_page!(id)

    ids = CmsPageVariants.list_ids_for_page(id)

    CmsPageVariantBlocks.delete_blocks_for_cms_page_variants(ids)
    CmsPageVariants.delete_cms_page_variants(ids)

    {:ok, _} = CmsPages.delete_cms_page(cms_page)
  end
end
