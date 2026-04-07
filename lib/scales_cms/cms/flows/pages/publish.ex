defmodule ScalesCms.Cms.Flows.Pages.Publish do
  @moduledoc """
  A collections of flows to aid publishing
  """
  alias ScalesCms.Cms.CmsPageLocaleLatestVariants
  alias ScalesCms.Cms.CmsPageVariant
  alias ScalesCms.Cms.CmsPageVariantBlocks
  alias ScalesCms.Cms.CmsPageVariants
  alias ScalesCms.Helpers.BlockResolver

  def perform(%CmsPageVariant{} = cms_page_variant) do
    with :ok <- resolve_snapshot_blocks(cms_page_variant),
         {:ok, _} <- set_to_latest_published(cms_page_variant) do
      CmsPageVariants.update_cms_page_variant(cms_page_variant, %{
        published_at: DateTime.utc_now()
      })
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
        CmsPageLocaleLatestVariants.create_cms_page_locale_latest_variant(%{
          cms_page_id: variant.cms_page_id,
          locale: variant.locale,
          cms_page_latest_published_variant_id: variant.id,
          cms_page_latest_variant_id: latest_variant_id
        })

      cplv ->
        CmsPageLocaleLatestVariants.update_cms_page_locale_latest_variant(cplv, %{
          cms_page_latest_published_variant_id: variant.id
        })
    end
  end

  defp resolve_snapshot_blocks(%CmsPageVariant{} = page_variant) do
    page_variant.id
    |> CmsPageVariantBlocks.list_blocks_for_page_variant()
    |> Enum.filter(&(&1.block_template_mode == :snapshot))
    |> Enum.reduce_while(:ok, fn block, :ok ->
      case resolve_snapshot_block(block, page_variant.locale) do
        :ok -> {:cont, :ok}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp resolve_snapshot_block(block, locale) do
    with {:ok, resolved_block} <- BlockResolver.resolve_block_from_template(block, locale),
         {:ok, _updated_block} <-
           CmsPageVariantBlocks.update_cms_page_variant_block(
             block,
             snapshot_block_attrs(resolved_block)
           ) do
      :ok
    end
  end

  defp snapshot_block_attrs(resolved_block) do
    %{
      component_type: resolved_block.component_type,
      properties: resolved_block.properties || %{}
    }
  end
end
