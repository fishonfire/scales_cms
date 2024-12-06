defmodule GlorioCms.Cms.Flows.Blocks.ReorderBlocks do
  @moduledoc """
    Set the new order of blocks after moving them
  """
  alias GlorioCms.Cms.CmsPageVariantBlock

  alias Ecto.Multi
  import Ecto.Query, warn: false

  use GlorioCms.RepoOverride

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
    |> Repo.transaction()
  end
end
