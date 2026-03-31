defmodule ScalesCms.Cms.Flows.Blocks.InsertBlock do
  @moduledoc """
  Insert a block in a list and fix the sorting of that list of blocks.
  Supports both regular component blocks and template-backed blocks.
  """

  alias ScalesCms.Cms.{
    CmsBlockTemplates,
    CmsPageVariantBlock,
    CmsPageVariantBlocks
  }

  import Ecto.Query, warn: false
  import ScalesCms, only: [repo: 0]

  def perform(block_index, type, page_variant_id) do
    repo().transaction(fn ->
      attrs =
        case build_block_attrs(type, page_variant_id) do
          {:ok, attrs} -> attrs
          {:error, reason} -> repo().rollback(reason)
        end

      CmsPageVariantBlock
      |> where(
        [pvb],
        pvb.cms_page_variant_id == ^page_variant_id and pvb.sort_order >= ^block_index
      )
      |> update(inc: [sort_order: 1])
      |> repo().update_all([])

      case CmsPageVariantBlocks.create_cms_page_variant_block(
             Map.merge(attrs, %{
               sort_order: block_index,
               cms_page_variant_id: page_variant_id
             })
           ) do
        {:ok, block} -> block
        {:error, changeset} -> repo().rollback(changeset)
      end
    end)
  end

  defp build_block_attrs("template:" <> template_family_id, page_variant_id) do
    case CmsBlockTemplates.get_for_page_variant(template_family_id, page_variant_id) do
      nil ->
        {:error, :template_not_found}

      template ->
        {:ok,
         %{
           component_type: template.component_type,
           block_template_family_id: template.template_family_id,
           block_template_mode: template.template_mode
         }}
    end
  end

  defp build_block_attrs(component_type, _page_variant_id) do
    {:ok,
     %{
       component_type: component_type,
       block_template_family_id: nil,
       block_template_mode: nil
     }}
  end
end
