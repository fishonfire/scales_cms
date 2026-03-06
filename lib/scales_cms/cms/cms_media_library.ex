defmodule ScalesCms.Cms.CmsMediaLibrary do
  @moduledoc """
  The CmsMediaLibrary context.
  """

  import Ecto.Query, warn: false
  alias ScalesCms.Cms.CmsMediaLibraryItem

  import ScalesCms, only: [repo: 0]

  @doc """
  Returns the list of all media library items.

  ## Examples

      iex> list_media_library_items()
      [%CmsMediaLibraryItem{}, ...]

  """
  def list_media_library_items do
    CmsMediaLibraryItem
    |> where([m], is_nil(m.deleted_at))
    |> order_by([m], desc: m.inserted_at)
    |> repo().all()
  end

  @doc """
  Returns the list of media library items filtered by type.

  ## Examples

      iex> list_media_library_items_by_type("image")
      [%CmsMediaLibraryItem{}, ...]

  """
  def list_media_library_items_by_type(type) do
    CmsMediaLibraryItem
    |> where([m], m.type == ^type)
    |> where([m], is_nil(m.deleted_at))
    |> order_by([m], desc: m.inserted_at)
    |> repo().all()
  end

  @doc """
  Searches media library items by name.

  ## Examples

      iex> search_media_library_items("logo")
      [%CmsMediaLibraryItem{}, ...]

  """
  def search_media_library_items(query) do
    CmsMediaLibraryItem
    |> where([m], is_nil(m.deleted_at))
    |> where([m], ilike(m.name, ^"%#{query}%"))
    |> order_by([m], desc: m.inserted_at)
    |> repo().all()
  end

  @doc """
  Searches media library items by name and type.

  ## Examples

      iex> search_media_library_items("logo", "image")
      [%CmsMediaLibraryItem{}, ...]

  """
  def search_media_library_items(query, type) do
    CmsMediaLibraryItem
    |> where([m], is_nil(m.deleted_at))
    |> where([m], m.type == ^type)
    |> where([m], ilike(m.name, ^"%#{query}%"))
    |> order_by([m], desc: m.inserted_at)
    |> repo().all()
  end

  @doc """
  Gets a single media library item.

  Raises `Ecto.NoResultsError` if the item does not exist.

  ## Examples

      iex> get_media_library_item!(123)
      %CmsMediaLibraryItem{}

      iex> get_media_library_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_media_library_item!(id), do: repo().get!(CmsMediaLibraryItem, id)

  @doc """
  Gets a single media library item.

  Returns `nil` if the item does not exist.

  ## Examples

      iex> get_media_library_item(123)
      %CmsMediaLibraryItem{}

      iex> get_media_library_item(456)
      nil

  """
  def get_media_library_item(id), do: repo().get(CmsMediaLibraryItem, id)

  @doc """
  Creates a media library item.

  ## Examples

      iex> create_media_library_item(%{field: value})
      {:ok, %CmsMediaLibraryItem{}}

      iex> create_media_library_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_media_library_item(attrs \\ %{}) do
    %CmsMediaLibraryItem{}
    |> CmsMediaLibraryItem.changeset(attrs)
    |> repo().insert()
  end

  @doc """
  Updates a media library item.

  ## Examples

      iex> update_media_library_item(media_library_item, %{field: new_value})
      {:ok, %CmsMediaLibraryItem{}}

      iex> update_media_library_item(media_library_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_media_library_item(%CmsMediaLibraryItem{} = media_library_item, attrs) do
    media_library_item
    |> CmsMediaLibraryItem.changeset(attrs)
    |> repo().update()
  end

  @doc """
  Soft deletes a media library item by setting deleted_at.

  ## Examples

      iex> delete_media_library_item(media_library_item)
      {:ok, %CmsMediaLibraryItem{}}

      iex> delete_media_library_item(media_library_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_media_library_item(%CmsMediaLibraryItem{} = media_library_item) do
    media_library_item
    |> CmsMediaLibraryItem.changeset(%{deleted_at: NaiveDateTime.utc_now()})
    |> repo().update()
  end

  @doc """
  Hard deletes a media library item from the database.

  ## Examples

      iex> hard_delete_media_library_item(media_library_item)
      {:ok, %CmsMediaLibraryItem{}}

      iex> hard_delete_media_library_item(media_library_item)
      {:error, %Ecto.Changeset{}}

  """
  def hard_delete_media_library_item(%CmsMediaLibraryItem{} = media_library_item) do
    repo().delete(media_library_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking media library item changes.

  ## Examples

      iex> change_media_library_item(media_library_item)
      %Ecto.Changeset{data: %CmsMediaLibraryItem{}}

  """
  def change_media_library_item(%CmsMediaLibraryItem{} = media_library_item, attrs \\ %{}) do
    CmsMediaLibraryItem.changeset(media_library_item, attrs)
  end
end
