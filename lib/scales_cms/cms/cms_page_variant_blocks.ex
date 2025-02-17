defmodule ScalesCms.Cms.CmsPageVariantBlocks do
  @moduledoc """
  The Cms context.
  """

  import Ecto.Query, warn: false
  alias ScalesCms.Cms.CmsPageVariantBlock
  import ScalesCms, only: [repo: 0]

  @doc """
  Returns the list of cms_page_variant_blocks.

  ## Examples

      iex> list_cms_page_variant_blocks()
      [%CmsPageVariantBlock{}, ...]

  """
  def list_cms_page_variant_blocks do
    repo().all(CmsPageVariantBlock)
  end

  def list_blocks_for_page_variant(page_variant_id) do
    CmsPageVariantBlock
    |> where([pvb], pvb.cms_page_variant_id == ^page_variant_id)
    |> order_by([pvb], asc: pvb.sort_order)
    |> repo().all()
  end

  @doc """
  Gets a single cms_page_variant_block.

  Raises `Ecto.NoResultsError` if the Cms page variant block does not exist.

  ## Examples

      iex> get_cms_page_variant_block!(123)
      %CmsPageVariantBlock{}

      iex> get_cms_page_variant_block!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cms_page_variant_block!(id), do: repo().get!(CmsPageVariantBlock, id)

  @doc """
  Creates a cms_page_variant_block.

  ## Examples

      iex> create_cms_page_variant_block(%{field: value})
      {:ok, %CmsPageVariantBlock{}}

      iex> create_cms_page_variant_block(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cms_page_variant_block(attrs \\ %{}) do
    %CmsPageVariantBlock{}
    |> CmsPageVariantBlock.changeset(attrs)
    |> repo().insert()
  end

  @doc """
  Updates a cms_page_variant_block.

  ## Examples

      iex> update_cms_page_variant_block(cms_page_variant_block, %{field: new_value})
      {:ok, %CmsPageVariantBlock{}}

      iex> update_cms_page_variant_block(cms_page_variant_block, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cms_page_variant_block(%CmsPageVariantBlock{} = cms_page_variant_block, attrs) do
    cms_page_variant_block
    |> CmsPageVariantBlock.changeset(attrs)
    |> repo().update()
  end

  @doc """
  Deletes a cms_page_variant_block.

  ## Examples

      iex> delete_cms_page_variant_block(cms_page_variant_block)
      {:ok, %CmsPageVariantBlock{}}

      iex> delete_cms_page_variant_block(cms_page_variant_block)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cms_page_variant_block(%CmsPageVariantBlock{} = cms_page_variant_block) do
    repo().delete(cms_page_variant_block)
  end

  @doc """
  Adds embedded element in a cms_page_variant_block by embedded field name.

  ## Examples

      iex> add_cms_page_variant_block_embedded_element(cms_page_variant_block, "buttons")
      {:ok, %CmsPageVariantBlock{}}

      iex> add_cms_page_variant_block_embedded_element(cms_page_variant_block)
      {:error, %Ecto.Changeset{}}

  """
  def add_cms_page_variant_block_embedded_element(
        %CmsPageVariantBlock{} = cms_page_variant_block,
        embedded_field
      ) do
    buttons = Map.get(cms_page_variant_block.properties, embedded_field, []) ++ [%{}]

    update_cms_page_variant_block(cms_page_variant_block, %{
      properties: Map.merge(cms_page_variant_block.properties, %{embedded_field => buttons})
    })
  end

  @doc """
  Deletes embedded element in a cms_page_variant_block by embedded field name and index.

  ## Examples

      iex> delete_cms_page_variant_block_embedded_element(cms_page_variant_block, "buttons", "0")
      {:ok, %CmsPageVariantBlock{}}

      iex> delete_cms_page_variant_block_embedded_element(cms_page_variant_block)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cms_page_variant_block_embedded_element(
        %CmsPageVariantBlock{} = cms_page_variant_block,
        embedded_field,
        embedded_index
      ) do
    buttons =
      Map.get(cms_page_variant_block.properties, embedded_field, [])
      |> List.delete_at(String.to_integer(embedded_index))

    update_cms_page_variant_block(cms_page_variant_block, %{
      properties: Map.merge(cms_page_variant_block.properties, %{embedded_field => buttons})
    })
  end

  def delete_blocks_for_cms_page_variants(page_variant_ids) do
    CmsPageVariantBlock
    |> where([pvb], pvb.cms_page_variant_id in ^page_variant_ids)
    |> repo().delete_all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cms_page_variant_block changes.

  ## Examples

      iex> change_cms_page_variant_block(cms_page_variant_block)
      %Ecto.Changeset{data: %CmsPageVariantBlock{}}

  """
  def change_cms_page_variant_block(%CmsPageVariantBlock{} = cms_page_variant_block, attrs \\ %{}) do
    CmsPageVariantBlock.changeset(cms_page_variant_block, attrs)
  end
end
