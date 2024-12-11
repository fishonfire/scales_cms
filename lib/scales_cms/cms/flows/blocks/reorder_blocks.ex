defmodule ScalesCms.Cms.Flows.Blocks.ReorderBlocks do
  @moduledoc """
    Set the new order of blocks after moving them
  """
  alias ScalesCms.Cms.CmsPageVariantBlock

  alias Ecto.Multi
  import Ecto.Query, warn: false
  import ScalesCms, only: [repo: 0]

  def perform(new_order) do
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
    |> repo().transaction()
  end
end
