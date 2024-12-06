defmodule GlorioCms.Cms.Flows.BlocksFlows do
  @moduledoc """
  Flows for working with the building blocks
  """
  alias GlorioCms.Cms.CmsPageVariantBlock
  alias GlorioCms.Cms.CmsPageVariantBlocks

  alias Ecto.Multi
  import Ecto.Query, warn: false

  use GlorioCms.RepoOverride

  def insert_block(block_index, type, page_variant_id) do
    with {:ok, _result} <-
           Repo.transaction(fn ->
             CmsPageVariantBlock
             |> where(
               [pvb],
               pvb.cms_page_variant_id == ^page_variant_id and pvb.sort_order >= ^block_index
             )
             |> update(inc: [sort_order: 1])
             |> Repo.update_all([])
           end) do
      CmsPageVariantBlocks.create_cms_page_variant_block(%{
        sort_order: block_index,
        component_type: type,
        cms_page_variant_id: page_variant_id
      })
    end
  end

  def reorder_blocks(new_order) do
    Enum.with_index(new_order)
    |> Enum.reduce(Multi.new(), fn {block_id, new_order}, multi ->
      {block_id, _} = Integer.parse(block_id)

      Multi.update(
        multi,
        {:cms_page_variant_block, block_id},
        CmsPageVariantBlock.change_order_changeset(%CmsPageVariantBlock{id: block_id}, %{
          sort_order: new_order
        })
      )
    end)
    |> Repo.transaction()
  end
end
