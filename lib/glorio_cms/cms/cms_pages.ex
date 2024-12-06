defmodule GlorioCms.Cms.CmsPages do
  @moduledoc """
  The Cms context.
  """

  import Ecto.Query, warn: false
  use GlorioCms.RepoOverride

  alias GlorioCms.Cms.CmsPage

  @doc """
  Returns the list of cms_pages.

  ## Examples

      iex> list_cms_pages()
      [%CmsPage{}, ...]

  """
  def list_cms_pages do
    CmsPage
    |> where([cp], is_nil(cp.cms_directory_id))
    |> Repo.all()
  end

  @doc """
  Returns the list of cms_pages within a directory.

  ## Examples

      iex> list_pages_for_directory_id(23)
      [%CmsPage{}, ...]

  """
  def list_pages_for_directory_id(directory_id) do
    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> Repo.all()
  end

  @doc """
  Gets a single cms_page.

  Raises `Ecto.NoResultsError` if the Cms page does not exist.

  ## Examples

      iex> get_cms_page!(123)
      %CmsPage{}

      iex> get_cms_page!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cms_page!(id), do: Repo.get!(CmsPage, id)

  @doc """
  Creates a cms_page.

  ## Examples

      iex> create_cms_page(%{field: value})
      {:ok, %CmsPage{}}

      iex> create_cms_page(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cms_page(attrs \\ %{}) do
    %CmsPage{}
    |> CmsPage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cms_page.

  ## Examples

      iex> update_cms_page(cms_page, %{field: new_value})
      {:ok, %CmsPage{}}

      iex> update_cms_page(cms_page, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cms_page(%CmsPage{} = cms_page, attrs) do
    cms_page
    |> CmsPage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cms_page.

  ## Examples

      iex> delete_cms_page(cms_page)
      {:ok, %CmsPage{}}

      iex> delete_cms_page(cms_page)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cms_page(%CmsPage{} = cms_page) do
    Repo.delete(cms_page)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cms_page changes.

  ## Examples

      iex> change_cms_page(cms_page)
      %Ecto.Changeset{data: %CmsPage{}}

  """
  def change_cms_page(%CmsPage{} = cms_page, attrs \\ %{}) do
    CmsPage.changeset(cms_page, attrs)
  end
end
