defmodule ScalesCms.Helpers.BlockResolver do
  @moduledoc """
  Resolves block based on if it has a template assigned to it.
  """
  alias ScalesCms.Cms.CmsBlockTemplate
  alias ScalesCms.Cms.CmsBlockTemplates
  alias ScalesCms.Cms.CmsPageVariantBlock

  def resolve_block(%CmsPageVariantBlock{block_template_family_id: nil} = block, _locale) do
    {:ok, block}
  end

  def resolve_block(
        %CmsPageVariantBlock{
          block_template_family_id: _family_id,
          block_template_mode: :snapshot
        } = block,
        _locale
      ) do
    {:ok, block}
  end

  def resolve_block(
        %CmsPageVariantBlock{
          block_template_family_id: family_id,
          block_template_mode: :live
        } = block,
        locale
      ) do
    case CmsBlockTemplates.get_by_family_and_locale(family_id, locale) do
      nil ->
        {:error, :template_not_found}

      template ->
        {:ok,
         %{
           block
           | component_type: template.component_type,
             properties: template.properties || %{}
         }}
    end
  end

  def resolve_block(%CmsPageVariantBlock{} = block, _locale) do
    {:ok, block}
  end

  def resolve_block(%CmsBlockTemplate{} = block, _locale), do: {:ok, block}

  def resolve_block_from_template(
        %CmsPageVariantBlock{block_template_family_id: nil} = block,
        _locale
      ) do
    {:ok, block}
  end

  def resolve_block_from_template(
        %CmsBlockTemplate{} = block,
        _locale
      ) do
    {:ok, block}
  end

  def resolve_block_from_template(
        %CmsPageVariantBlock{block_template_family_id: family_id} = block,
        locale
      ) do
    case CmsBlockTemplates.get_by_family_and_locale(family_id, locale) do
      nil ->
        {:error, :template_not_found}

      template ->
        {:ok,
         %{
           block
           | component_type: template.component_type,
             properties: template.properties || %{}
         }}
    end
  end

  def template_block?(%CmsPageVariantBlock{block_template_family_id: nil}), do: false
  def template_block?(%CmsPageVariantBlock{}), do: true

  def template_block?(%CmsBlockTemplate{}), do: true
end
