defmodule GlorioCms.Cms.CmsDirectories do
  @moduledoc """
  The Cms context.
  """

  import Ecto.Query, warn: false
  use GlorioCms.RepoOverride

  alias GlorioCms.Cms.CmsDirectory

  @doc """
  Returns the list of cms_directories.

  ## Examples

      iex> list_cms_directories()
      [%CmsDirectory{}, ...]

  """
  def list_cms_directories do
    CmsDirectory
    |> where([cd], is_nil(cd.cms_directory_id))
    |> Repo.all()
  end

  @doc """
  Returns the list of cms_directories under its parent id.

  ## Examples

      iex> list_cms_directories(12)
      [%CmsDirectory{}, ...]

  """
  def list_cms_directories_for_parent_id(parent_id) do
    CmsDirectory
    |> where([cd], cd.cms_directory_id == ^parent_id)
    |> Repo.all()
  end

  @doc """
  Gets a single cms_directory.

  Raises `Ecto.NoResultsError` if the Cms directory does not exist.

  ## Examples

      iex> get_cms_directory!(123)
      %CmsDirectory{}

      iex> get_cms_directory!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cms_directory!(id), do: Repo.get!(CmsDirectory, id)

  @doc """
  Creates a cms_directory.

  ## Examples

      iex> create_cms_directory(%{field: value})
      {:ok, %CmsDirectory{}}

      iex> create_cms_directory(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cms_directory(attrs \\ %{}) do
    %CmsDirectory{}
    |> CmsDirectory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cms_directory.

  ## Examples

      iex> update_cms_directory(cms_directory, %{field: new_value})
      {:ok, %CmsDirectory{}}

      iex> update_cms_directory(cms_directory, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cms_directory(%CmsDirectory{} = cms_directory, attrs) do
    cms_directory
    |> CmsDirectory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cms_directory.

  ## Examples

      iex> delete_cms_directory(cms_directory)
      {:ok, %CmsDirectory{}}

      iex> delete_cms_directory(cms_directory)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cms_directory(%CmsDirectory{} = cms_directory) do
    Repo.delete(cms_directory)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cms_directory changes.

  ## Examples

      iex> change_cms_directory(cms_directory)
      %Ecto.Changeset{data: %CmsDirectory{}}

  """
  def change_cms_directory(%CmsDirectory{} = cms_directory, attrs \\ %{}) do
    CmsDirectory.changeset(cms_directory, attrs)
  end
end
