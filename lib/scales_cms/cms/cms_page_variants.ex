defmodule ScalesCms.Cms.CmsPageVariants do
  @moduledoc """
  The Cms context.
  """

  import Ecto.Query, warn: false
  alias ScalesCms.Cms.CmsPageVariant
  import ScalesCms, only: [repo: 0]

  @doc """
  Returns the list of cms_page_variants.

  ## Examples

      iex> list_cms_page_variants()
      [%CmsPageVariant{}, ...]

  """
  def list_cms_page_variants do
    repo().all(CmsPageVariant)
  end

  @doc """
  Returns the list of cms_page_variants for a page.

  ## Examples

      iex> list_cms_page_variants_for_page(232)
      [%CmsPageVariant{}, ...]

  """
  def list_cms_page_variants_for_page(page_id) do
    CmsPageVariant
    |> where([cpv], cpv.cms_page_id == ^page_id)
    |> repo().all()
  end

  @doc """
  Returns the list of cms_page_variants for a page and a specified locale.

  ## Examples

      iex> list_cms_page_variants_for_page_and_locale(232, "nl-NL")
      [%CmsPageVariant{}, ...]

  """
  def list_cms_page_variants_for_page_and_locale(page_id, locale) do
    CmsPageVariant
    |> where([cpv], cpv.cms_page_id == ^page_id and cpv.locale == ^locale)
    |> repo().all()
  end

  def list_ids_for_page(page_id) do
    CmsPageVariant
    |> where([cpv], cpv.cms_page_id == ^page_id)
    |> select([cpv], cpv.id)
    |> repo().all()
  end

  @doc """
  Gets a single cms_page_variant.

  Raises `Ecto.NoResultsError` if the Cms page variant does not exist.

  ## Examples

      iex> get_cms_page_variant!(123)
      %CmsPageVariant{}

      iex> get_cms_page_variant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cms_page_variant!(id), do: repo().get!(CmsPageVariant, id)

  def get_latest_cms_page_variant_for_locale(page_id, locale) do
    CmsPageVariant
    |> where([cpv], cpv.cms_page_id == ^page_id and cpv.locale == ^locale)
    |> order_by([cpv], desc: cpv.version)
    |> limit(1)
    |> repo().one()
  end

  @doc """
  Creates a cms_page_variant.

  ## Examples

      iex> create_cms_page_variant(%{field: value})
      {:ok, %CmsPageVariant{}}

      iex> create_cms_page_variant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cms_page_variant(attrs \\ %{}) do
    %CmsPageVariant{}
    |> CmsPageVariant.changeset(attrs)
    |> repo().insert()
  end

  @doc """
  Updates a cms_page_variant.

  ## Examples

      iex> update_cms_page_variant(cms_page_variant, %{field: new_value})
      {:ok, %CmsPageVariant{}}

      iex> update_cms_page_variant(cms_page_variant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cms_page_variant(%CmsPageVariant{} = cms_page_variant, attrs) do
    cms_page_variant
    |> CmsPageVariant.changeset(attrs)
    |> repo().update()
  end

  @doc """
  Deletes a cms_page_variant.

  ## Examples

      iex> delete_cms_page_variant(cms_page_variant)
      {:ok, %CmsPageVariant{}}

      iex> delete_cms_page_variant(cms_page_variant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cms_page_variant(%CmsPageVariant{} = cms_page_variant) do
    repo().delete(cms_page_variant)
  end

  @doc """
    Deletes a cms_page_variants.

    ## Examples

        iex> delete_cms_page_variant([1, 2, 3])
        {3, [%CmsPageVariant{}, %CmsPageVariant{}, %CmsPageVariant{}]}

        iex> delete_cms_page_variant([0])
        {:0, []}
  """

  def delete_cms_page_variants(ids) do
    CmsPageVariant
    |> where([cpv], cpv.id in ^ids)
    |> repo().delete_all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cms_page_variant changes.

  ## Examples

      iex> change_cms_page_variant(cms_page_variant)
      %Ecto.Changeset{data: %CmsPageVariant{}}

  """
  def change_cms_page_variant(%CmsPageVariant{} = cms_page_variant, attrs \\ %{}) do
    CmsPageVariant.changeset(cms_page_variant, attrs)
  end
end
