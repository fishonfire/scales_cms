defmodule GlorioCms.Cms.CmsPageLocaleLatestVariants do
  @moduledoc """
  The Cms context.
  """

  import Ecto.Query, warn: false

  alias GlorioCms.Repo

  alias GlorioCms.Cms.CmsPageLocaleLatestVariant

  @doc """
  Returns the list of cms_page_locale_latest_variants.

  ## Examples

      iex> list_cms_page_locale_latest_variants()
      [%CmsPageVariant{}, ...]

  """
  def list_cms_page_locale_latest_variants do
    Repo.all(CmsPageLocaleLatestVariant)
  end

  @doc """
  Returns the list of cms_page_locale_latest_variants for a page and a specified locale.

  ## Examples

      iex> list_cms_page_locale_latest_variants_for_page_and_locale(232, "nl-NL")
      [%CmsPageVariant{}, ...]

  """
  def list_cms_page_locale_latest_variants_for_page_and_locale(page_id, locale) do
    CmsPageLocaleLatestVariant
    |> where([cpv], cpv.cms_page_id == ^page_id and cpv.locale == ^locale)
    |> Repo.all()
  end

  @doc """
  Gets a single cms_page_locale_latest_variant.

  Raises `Ecto.NoResultsError` if the Cms page variant does not exist.

  ## Examples

      iex> get_cms_page_locale_latest_variant!(123)
      %CmsPageVariant{}

      iex> get_cms_page_locale_latest_variant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cms_page_locale_latest_variant!(id), do: Repo.get!(CmsPageLocaleLatestVariant, id)

  def get_cms_page_locale_latest_variant_for_page_and_locale(page_id, locale) do
    CmsPageLocaleLatestVariant
    |> where([cplv], cplv.cms_page_id == ^page_id and cplv.locale == ^locale)
    |> Repo.one()
  end

  @doc """
  Creates a cms_page_locale_latest_variant.

  ## Examples

      iex> create_cms_page_locale_latest_variant(%{field: value})
      {:ok, %CmsPageVariant{}}

      iex> create_cms_page_locale_latest_variant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cms_page_locale_latest_variant(attrs \\ %{}) do
    %CmsPageLocaleLatestVariant{}
    |> CmsPageLocaleLatestVariant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cms_page_locale_latest_variant.

  ## Examples

      iex> update_cms_page_locale_latest_variant(cms_page_locale_latest_variant, %{field: new_value})
      {:ok, %CmsPageVariant{}}

      iex> update_cms_page_locale_latest_variant(cms_page_locale_latest_variant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cms_page_locale_latest_variant(
        %CmsPageLocaleLatestVariant{} = cms_page_locale_latest_variant,
        attrs
      ) do
    cms_page_locale_latest_variant
    |> CmsPageLocaleLatestVariant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cms_page_locale_latest_variant.

  ## Examples

      iex> delete_cms_page_locale_latest_variant(cms_page_locale_latest_variant)
      {:ok, %CmsPageVariant{}}

      iex> delete_cms_page_locale_latest_variant(cms_page_locale_latest_variant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cms_page_locale_latest_variant(
        %CmsPageLocaleLatestVariant{} = cms_page_locale_latest_variant
      ) do
    Repo.delete(cms_page_locale_latest_variant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cms_page_locale_latest_variant changes.

  ## Examples

      iex> change_cms_page_locale_latest_variant(cms_page_locale_latest_variant)
      %Ecto.Changeset{data: %CmsPageVariant{}}

  """
  def change_cms_page_locale_latest_variant(
        %CmsPageLocaleLatestVariant{} = cms_page_locale_latest_variant,
        attrs \\ %{}
      ) do
    CmsPageLocaleLatestVariant.changeset(cms_page_locale_latest_variant, attrs)
  end
end
