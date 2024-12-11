defmodule GlorioCms.Cms.Flows.Blocks.InsertBlock do
  @moduledoc """
  Insert a block in a list and fix the sorting of that list of blocks
  """
  alias GlorioCms.Cms.CmsPageVariantBlock
  alias GlorioCms.Cms.CmsPageVariantBlocks

  import Ecto.Query, warn: false
  import GlorioCms, only: [repo: 0]

  def perform(block_index, type, page_variant_id) do
    with {:ok, _result} <-
           repo().transaction(fn ->
             CmsPageVariantBlock
             |> where(
               [pvb],
               pvb.cms_page_variant_id == ^page_variant_id and pvb.sort_order >= ^block_index
             )
             |> update(inc: [sort_order: 1])
             |> repo().update_all([])
           end) do
      CmsPageVariantBlocks.create_cms_page_variant_block(%{
        sort_order: block_index,
        component_type: type,
        cms_page_variant_id: page_variant_id
      })
    end
  end
end
