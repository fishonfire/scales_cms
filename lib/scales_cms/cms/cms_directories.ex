defmodule ScalesCms.Cms.CmsDirectories do
  @moduledoc """
  The Cms context.
  """

  import Ecto.Query, warn: false
  alias ScalesCms.Cms.CmsDirectory

  import ScalesCms, only: [repo: 0]

  @doc """
  Returns the list of cms_directories.

  ## Examples

      iex> list_cms_directories()
      [%CmsDirectory{}, ...]

  """
  def list_cms_directories do
    CmsDirectory
    |> where([cd], is_nil(cd.cms_directory_id))
    |> repo().all()
  end

  @doc """
  Fetches directories with optional search query and sorting.
  Used for root-level directory listing.

  ## Options

    * `:sort_by` - Column to sort by: "created"
    * `:sort_order` - Sort direction: "asc" or "desc" (default: "asc")

  ## Examples

      iex> fetch_directories("", sort_by: "created", sort_order: "desc")
      [%CmsDirectory{}, ...]

  """
  def fetch_directories(query, opts \\ [])

  def fetch_directories("", opts) do
    CmsDirectory
    |> where([cd], is_nil(cd.cms_directory_id))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> repo().all()
  end

  def fetch_directories(query, opts) do
    CmsDirectory
    |> where([cd], is_nil(cd.cms_directory_id))
    |> where([cd], ilike(cd.title, ^"%#{query}%"))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> repo().all()
  end

  @doc """
  Fetches paginated directories with optional search query and sorting.
  Used for root-level directory listing.

  ## Options

    * `:sort_by` - Column to sort by: "created"
    * `:sort_order` - Sort direction: "asc" or "desc" (default: "asc")
    * `:page` - Page number (1-based)
    * `:per_page` - Number of items per page

  ## Examples

      iex> fetch_paginated_directories("", page: 1, per_page: 20, sort_by: "created", sort_order: "desc")
      [%CmsDirectory{}, ...]

  """
  def fetch_paginated_directories(query, opts \\ [])

  def fetch_paginated_directories("", opts) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)
    offset = (page - 1) * per_page

    CmsDirectory
    |> where([cd], is_nil(cd.cms_directory_id))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> limit(^per_page)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_paginated_directories(query, opts) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)
    offset = (page - 1) * per_page

    CmsDirectory
    |> where([cd], is_nil(cd.cms_directory_id))
    |> where([cd], ilike(cd.title, ^"%#{query}%"))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> limit(^per_page)
    |> offset(^offset)
    |> repo().all()
  end

  @doc """
  Counts directories with optional search query.
  Used for root-level directory listing pagination.

  ## Examples

      iex> count_directories("")
      10

  """
  def count_directories(query \\ "")

  def count_directories("") do
    CmsDirectory
    |> where([cd], is_nil(cd.cms_directory_id))
    |> select([cd], count(cd.id))
    |> repo().one()
  end

  def count_directories(query) do
    CmsDirectory
    |> where([cd], is_nil(cd.cms_directory_id))
    |> where([cd], ilike(cd.title, ^"%#{query}%"))
    |> select([cd], count(cd.id))
    |> repo().one()
  end

  @doc """
  Fetches directories for a parent with optional search query and sorting.

  ## Options

    * `:sort_by` - Column to sort by: "created"
    * `:sort_order` - Sort direction: "asc" or "desc" (default: "asc")

  ## Examples

      iex> fetch_directories_for_parent(123, "", sort_by: "created", sort_order: "asc")
      [%CmsDirectory{}, ...]

  """
  def fetch_directories_for_parent(parent_id, query, opts \\ [])

  def fetch_directories_for_parent(parent_id, "", opts) do
    CmsDirectory
    |> where([cd], cd.cms_directory_id == ^parent_id)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> repo().all()
  end

  def fetch_directories_for_parent(parent_id, query, opts) do
    CmsDirectory
    |> where([cd], cd.cms_directory_id == ^parent_id)
    |> where([cd], ilike(cd.title, ^"%#{query}%"))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> repo().all()
  end

  @doc """
  Fetches paginated directories for a parent with optional search query and sorting.

  ## Options

    * `:sort_by` - Column to sort by: "created"
    * `:sort_order` - Sort direction: "asc" or "desc" (default: "asc")
    * `:page` - Page number (1-based)
    * `:per_page` - Number of items per page

  ## Examples

      iex> fetch_paginated_directories_for_parent(123, "", page: 1, per_page: 20, sort_by: "created", sort_order: "asc")
      [%CmsDirectory{}, ...]

  """
  def fetch_paginated_directories_for_parent(parent_id, query, opts \\ [])

  def fetch_paginated_directories_for_parent(parent_id, "", opts) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)
    offset = (page - 1) * per_page

    CmsDirectory
    |> where([cd], cd.cms_directory_id == ^parent_id)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> limit(^per_page)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_paginated_directories_for_parent(parent_id, query, opts) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)
    offset = (page - 1) * per_page

    CmsDirectory
    |> where([cd], cd.cms_directory_id == ^parent_id)
    |> where([cd], ilike(cd.title, ^"%#{query}%"))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> limit(^per_page)
    |> offset(^offset)
    |> repo().all()
  end

  @doc """
  Counts directories for a parent with optional search query.
  Used for pagination.

  ## Examples

      iex> count_directories_for_parent(123, "")
      5

  """
  def count_directories_for_parent(parent_id, query \\ "")

  def count_directories_for_parent(parent_id, "") do
    CmsDirectory
    |> where([cd], cd.cms_directory_id == ^parent_id)
    |> select([cd], count(cd.id))
    |> repo().one()
  end

  def count_directories_for_parent(parent_id, query) do
    CmsDirectory
    |> where([cd], cd.cms_directory_id == ^parent_id)
    |> where([cd], ilike(cd.title, ^"%#{query}%"))
    |> select([cd], count(cd.id))
    |> repo().one()
  end

  @doc """
  Returns the list of cms_directories matching the search query.

  ## Examples

      iex> search_cms_directories("blog")
      [%CmsDirectory{}, ...]

  """
  def search_cms_directories(search) do
    CmsDirectory
    |> where([cd], is_nil(cd.cms_directory_id))
    |> where([cd], ilike(cd.title, ^"%#{search}%"))
    |> repo().all()
  end

  @doc """
  Returns the list of all cms_directories.

  ## Examples

      iex> list_all_cms_directories()
      [%CmsDirectory{}, ...]

  """
  def list_all_cms_directories, do: repo().all(CmsDirectory)

  @doc """
  Returns the list of all active cms_directories.

  ## Examples

      iex> list_all_active_cms_directories()
      [%CmsDirectory{}, ...]

  """
  def list_all_active_cms_directories do
    CmsDirectory
    |> where([cd], is_nil(cd.deleted_at))
    |> repo().all()
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
    |> repo().all()
  end

  @doc """
  Returns the list of cms_directories under its parent id matching the search query.

  ## Examples

      iex> search_cms_directories_for_parent_id(12, "blog")
      [%CmsDirectory{}, ...]

  """
  def search_cms_directories_for_parent_id(parent_id, search) do
    CmsDirectory
    |> where([cd], cd.cms_directory_id == ^parent_id)
    |> where([cd], ilike(cd.title, ^"%#{search}%"))
    |> repo().all()
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
  def get_cms_directory!(id), do: repo().get!(CmsDirectory, id)

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
    |> repo().insert()
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
    |> repo().update()
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
    repo().delete(cms_directory)
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

  @doc """
  Applies sorting to a query based on the given column and order.

  ## Parameters

    * `query` - The Ecto query to sort
    * `sort_by` - Column to sort by: "created"
    * `sort_order` - Sort direction: "asc" or "desc" (default: "asc")

  ## Examples

      iex> apply_sorting(query, "created", "desc")
      #Ecto.Query<...>

  """
  def apply_sorting(query, sort_by, sort_order) do
    cond do
      sort_by == "created" && sort_order == "desc" ->
        query |> order_by([cd], desc: cd.inserted_at)

      sort_by == "created" ->
        query |> order_by([cd], asc: cd.inserted_at)

      true ->
        query
    end
  end

  @doc """
  Fetches a slice of root directories using offset/limit.
  Used by CmsListing for combined pagination.
  """
  def fetch_directories_slice(query, offset, limit, opts \\ [])

  def fetch_directories_slice("", offset, limit, opts) do
    CmsDirectory
    |> where([cd], is_nil(cd.cms_directory_id))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> limit(^limit)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_directories_slice(query, offset, limit, opts) do
    CmsDirectory
    |> where([cd], is_nil(cd.cms_directory_id))
    |> where([cd], ilike(cd.title, ^"%#{query}%"))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> limit(^limit)
    |> offset(^offset)
    |> repo().all()
  end

  @doc """
  Fetches a slice of child directories using offset/limit.
  Used by CmsListing for combined pagination.
  """
  def fetch_directories_for_parent_slice(parent_id, query, offset, limit, opts \\ [])

  def fetch_directories_for_parent_slice(parent_id, "", offset, limit, opts) do
    CmsDirectory
    |> where([cd], cd.cms_directory_id == ^parent_id)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> limit(^limit)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_directories_for_parent_slice(parent_id, query, offset, limit, opts) do
    CmsDirectory
    |> where([cd], cd.cms_directory_id == ^parent_id)
    |> where([cd], ilike(cd.title, ^"%#{query}%"))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> limit(^limit)
    |> offset(^offset)
    |> repo().all()
  end
end
