defmodule GlorioCms.Cms.CmsPageVariants do
  @moduledoc """
  The Cms context.
  """

  import Ecto.Query, warn: false
  alias GlorioCms.Repo

  alias GlorioCms.Cms.CmsPageVariant

  @doc """
  Returns the list of cms_page_variants.

  ## Examples

      iex> list_cms_page_variants()
      [%CmsPageVariant{}, ...]

  """
  def list_cms_page_variants do
    Repo.all(CmsPageVariant)
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
  def get_cms_page_variant!(id), do: Repo.get!(CmsPageVariant, id)

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
    |> Repo.insert()
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
    |> Repo.update()
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
    Repo.delete(cms_page_variant)
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
