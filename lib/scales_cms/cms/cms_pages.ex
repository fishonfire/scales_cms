defmodule ScalesCms.Cms.CmsPages do
  @moduledoc """
  The Cms context.
  """

  import Ecto.Query, warn: false
  alias ScalesCms.Cms.CmsPage
  alias ScalesCms.Cms.CmsPageLocaleLatestVariant
  import ScalesCms, only: [repo: 0]

  # Helper to add published status via subquery (avoids N+1 queries)
  defp with_published_status(query) do
    published_subquery =
      from v in CmsPageLocaleLatestVariant,
        where: parent_as(:cms_page).id == v.cms_page_id,
        where: not is_nil(v.cms_page_latest_published_variant_id),
        select: 1,
        limit: 1

    from cp in query,
      as: :cms_page,
      select_merge: %{published: exists(subquery(published_subquery))}
  end

  @doc """
  Returns the list of cms_pages.

  ## Examples

      iex> list_cms_pages()
      [%CmsPage{}, ...]

  """
  def list_cms_pages do
    CmsPage
    |> where([cp], is_nil(cp.cms_directory_id))
    |> with_published_status()
    |> repo().all()
  end

  @doc """
  Returns the list of cms_pages filtered by status.

  ## Examples

      iex> list_cms_pages("published")
      [%CmsPage{}, ...]

  """
  def list_cms_pages(status) when status in ["published", "draft"] do
    CmsPage
    |> where([cp], is_nil(cp.cms_directory_id))
    |> filter_by_status(status)
    |> with_published_status()
    |> repo().all()
  end

  def list_cms_pages(_status), do: list_cms_pages()

  @doc """
  Returns the list of paginated cms_pages.

  ## Examples

      iex> list_paginated_cms_pages(1, 25)
      [%CmsPage{}, ...]

  """
  def list_root_paginated_cms_pages(page, amount) do
    offset = page * amount

    CmsPage
    |> where([cp], is_nil(cp.cms_directory_id))
    |> limit(^amount)
    |> offset(^offset)
    |> preload(:directory)
    |> repo().all()
  end

  @doc """
  Returns the list of all paginated cms_pages.

  ## Examples

      iex> list_paginated_cms_pages(1, 25)
      [%CmsPage{}, ...]

  """
  def list_paginated_cms_pages(page, amount) do
    offset = page * amount

    CmsPage
    |> limit(^amount)
    |> offset(^offset)
    |> preload(:directory)
    |> repo().all()
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
    |> with_published_status()
    |> repo().all()
  end

  @doc """
  Returns the list of cms_pages within a directory filtered by status.

  ## Examples

      iex> list_pages_for_directory_id(23, "published")
      [%CmsPage{}, ...]

  """
  def list_pages_for_directory_id(directory_id, status) when status in ["published", "draft"] do
    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> filter_by_status(status)
    |> with_published_status()
    |> repo().all()
  end

  def list_pages_for_directory_id(directory_id, _status),
    do: list_pages_for_directory_id(directory_id)

  @doc """
  Returns the list of cms_pages within a directory.

  ## Examples

      iex> search_cms_pages_for_directory_id(23, "search term")
      [%CmsPage{}, ...]

  """
  def search_cms_pages_for_directory_id(directory_id, search) do
    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> where([cp], ilike(cp.title, ^"%#{search}%"))
    |> with_published_status()
    |> repo().all()
  end

  @doc """
  Returns the list of cms_pages within a directory filtered by search and status.

  ## Examples

      iex> search_cms_pages_for_directory_id(23, "Page title", "published")
      [%CmsPage{}, ...]

  """
  def search_cms_pages_for_directory_id(directory_id, search, status)
      when status in ["published", "draft"] do
    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> where([cp], ilike(cp.title, ^"%#{search}%"))
    |> filter_by_status(status)
    |> with_published_status()
    |> repo().all()
  end

  def search_cms_pages_for_directory_id(directory_id, search, _status),
    do: search_cms_pages_for_directory_id(directory_id, search)

  @doc """
  Returns the root list of searched pages.

  ## Examples

      iex> list_pages_for_directory_id("Page title")
      [%CmsPage{}, ...]

  """
  def search_cms_pages(query) do
    CmsPage
    |> where([cp], is_nil(cp.cms_directory_id))
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> with_published_status()
    |> preload(:directory)
    |> repo().all()
  end

  @doc """
  Returns the list of searched pages filtered by status.

  ## Examples

      iex> search_cms_pages("Page title", "published")
      [%CmsPage{}, ...]

  """
  def search_cms_pages(query, status) when status in ["published", "draft"] do
    CmsPage
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> filter_by_status(status)
    |> with_published_status()
    |> preload(:directory)
    |> repo().all()
  end

  def search_cms_pages(query, _status), do: search_cms_pages(query)

  @doc """
  Fetches pages with optional query, status filters, and sorting.
  Used for root-level page listing.

  ## Options

    * `:sort_by` - Column to sort by: "created", "views", or "status"
    * `:sort_order` - Sort direction: "asc" or "desc" (default: "asc")

  ## Examples

      iex> fetch_pages("", "")
      [%CmsPage{}, ...]

      iex> fetch_pages("search term", "published", sort_by: "views", sort_order: "desc")
      [%CmsPage{}, ...]

  """
  def fetch_pages(query, status, opts \\ [])

  def fetch_pages("", "", opts) do
    CmsPage
    |> where([cp], is_nil(cp.cms_directory_id))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> repo().all()
  end

  def fetch_pages("", status, opts) when status in ["published", "draft"] do
    CmsPage
    |> where([cp], is_nil(cp.cms_directory_id))
    |> filter_by_status(status)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> repo().all()
  end

  def fetch_pages("", _status, opts), do: fetch_pages("", "", opts)

  def fetch_pages(query, "", opts) do
    CmsPage
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> preload(:directory)
    |> with_published_status()
    |> repo().all()
  end

  def fetch_pages(query, status, opts) when status in ["published", "draft"] do
    CmsPage
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> filter_by_status(status)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> preload(:directory)
    |> with_published_status()
    |> repo().all()
  end

  def fetch_pages(query, _status, opts), do: fetch_pages(query, "", opts)

  @doc """
  Fetches paginated pages with optional query, status filters, and sorting.
  Used for root-level page listing with pagination.

  ## Options

    * `:sort_by` - Column to sort by: "created", "views", or "status"
    * `:sort_order` - Sort direction: "asc" or "desc" (default: "asc")

  ## Examples

      iex> fetch_paginated_pages("", "", 1, 20)
      [%CmsPage{}, ...]

  """
  def fetch_paginated_pages(query, status, page, per_page, opts \\ [])

  def fetch_paginated_pages("", "", page, per_page, opts) do
    offset = (page - 1) * per_page

    CmsPage
    |> where([cp], is_nil(cp.cms_directory_id))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> limit(^per_page)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_paginated_pages("", status, page, per_page, opts)
      when status in ["published", "draft"] do
    offset = (page - 1) * per_page

    CmsPage
    |> where([cp], is_nil(cp.cms_directory_id))
    |> filter_by_status(status)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> limit(^per_page)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_paginated_pages("", _status, page, per_page, opts),
    do: fetch_paginated_pages("", "", page, per_page, opts)

  def fetch_paginated_pages(query, "", page, per_page, opts) do
    offset = (page - 1) * per_page

    CmsPage
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> preload(:directory)
    |> with_published_status()
    |> limit(^per_page)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_paginated_pages(query, status, page, per_page, opts)
      when status in ["published", "draft"] do
    offset = (page - 1) * per_page

    CmsPage
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> filter_by_status(status)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> preload(:directory)
    |> with_published_status()
    |> limit(^per_page)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_paginated_pages(query, _status, page, per_page, opts),
    do: fetch_paginated_pages(query, "", page, per_page, opts)

  @doc """
  Counts pages with optional query and status filters.
  Used for pagination calculation.

  ## Examples

      iex> count_pages("", "")
      42

  """
  def count_pages(query, status)

  def count_pages("", "") do
    CmsPage
    |> where([cp], is_nil(cp.cms_directory_id))
    |> select([cp], count(cp.id))
    |> repo().one()
  end

  def count_pages("", status) when status in ["published", "draft"] do
    CmsPage
    |> where([cp], is_nil(cp.cms_directory_id))
    |> filter_by_status(status)
    |> select([cp], count(cp.id, :distinct))
    |> repo().one()
  end

  def count_pages("", _status), do: count_pages("", "")

  def count_pages(query, "") do
    CmsPage
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> select([cp], count(cp.id))
    |> repo().one()
  end

  def count_pages(query, status) when status in ["published", "draft"] do
    CmsPage
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> filter_by_status(status)
    |> select([cp], count(cp.id, :distinct))
    |> repo().one()
  end

  def count_pages(query, _status), do: count_pages(query, "")

  @doc """
  Fetches pages for a directory with optional query, status filters, and sorting.

  ## Options

    * `:sort_by` - Column to sort by: "created", "views", or "status"
    * `:sort_order` - Sort direction: "asc" or "desc" (default: "asc")

  ## Examples

      iex> fetch_pages_for_directory(123, "", "")
      [%CmsPage{}, ...]

      iex> fetch_pages_for_directory(123, "search term", "published", sort_by: "created", sort_order: "asc")
      [%CmsPage{}, ...]

  """
  def fetch_pages_for_directory(directory_id, query, status, opts \\ [])

  def fetch_pages_for_directory(directory_id, "", "", opts) do
    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> repo().all()
  end

  def fetch_pages_for_directory(directory_id, "", status, opts)
      when status in ["published", "draft"] do
    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> filter_by_status(status)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> repo().all()
  end

  def fetch_pages_for_directory(directory_id, "", _status, opts),
    do: fetch_pages_for_directory(directory_id, "", "", opts)

  def fetch_pages_for_directory(directory_id, query, "", opts) do
    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> repo().all()
  end

  def fetch_pages_for_directory(directory_id, query, status, opts)
      when status in ["published", "draft"] do
    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> filter_by_status(status)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> repo().all()
  end

  def fetch_pages_for_directory(directory_id, query, _status, opts),
    do: fetch_pages_for_directory(directory_id, query, "", opts)

  @doc """
  Fetches paginated pages for a directory with optional query, status filters, and sorting.

  ## Options

    * `:sort_by` - Column to sort by: "created", "views", or "status"
    * `:sort_order` - Sort direction: "asc" or "desc" (default: "asc")

  ## Examples

      iex> fetch_paginated_pages_for_directory(123, "", "", 1, 20)
      [%CmsPage{}, ...]

  """
  def fetch_paginated_pages_for_directory(directory_id, query, status, page, per_page, opts \\ [])

  def fetch_paginated_pages_for_directory(directory_id, "", "", page, per_page, opts) do
    offset = (page - 1) * per_page

    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> limit(^per_page)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_paginated_pages_for_directory(directory_id, "", status, page, per_page, opts)
      when status in ["published", "draft"] do
    offset = (page - 1) * per_page

    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> filter_by_status(status)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> limit(^per_page)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_paginated_pages_for_directory(directory_id, "", _status, page, per_page, opts),
    do: fetch_paginated_pages_for_directory(directory_id, "", "", page, per_page, opts)

  def fetch_paginated_pages_for_directory(directory_id, query, "", page, per_page, opts) do
    offset = (page - 1) * per_page

    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> limit(^per_page)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_paginated_pages_for_directory(directory_id, query, status, page, per_page, opts)
      when status in ["published", "draft"] do
    offset = (page - 1) * per_page

    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> filter_by_status(status)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> limit(^per_page)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_paginated_pages_for_directory(directory_id, query, _status, page, per_page, opts),
    do: fetch_paginated_pages_for_directory(directory_id, query, "", page, per_page, opts)

  @doc """
  Counts pages for a directory with optional query and status filters.
  Used for pagination calculation.

  ## Examples

      iex> count_pages_for_directory(123, "", "")
      15

  """
  def count_pages_for_directory(directory_id, query, status)

  def count_pages_for_directory(directory_id, "", "") do
    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> select([cp], count(cp.id))
    |> repo().one()
  end

  def count_pages_for_directory(directory_id, "", status) when status in ["published", "draft"] do
    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> filter_by_status(status)
    |> select([cp], count(cp.id, :distinct))
    |> repo().one()
  end

  def count_pages_for_directory(directory_id, "", _status),
    do: count_pages_for_directory(directory_id, "", "")

  def count_pages_for_directory(directory_id, query, "") do
    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> select([cp], count(cp.id))
    |> repo().one()
  end

  def count_pages_for_directory(directory_id, query, status)
      when status in ["published", "draft"] do
    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> filter_by_status(status)
    |> select([cp], count(cp.id, :distinct))
    |> repo().one()
  end

  def count_pages_for_directory(directory_id, query, _status),
    do: count_pages_for_directory(directory_id, query, "")

  @doc """
  Gets a single cms_page.

  Raises `Ecto.NoResultsError` if the Cms page does not exist.

  ## Examples

      iex> get_cms_page!(123)
      %CmsPage{}

      iex> get_cms_page!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cms_page!(id), do: repo().get!(CmsPage, id)

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
    |> repo().insert()
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
    |> repo().update()
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
    repo().delete(cms_page)
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

  def preload_directory(query) do
    repo().preload(query, :directory)
  end

  @doc """
  Checks if a page is published (has at least one published variant).
  """
  def published?(cms_page) do
    query =
      from v in CmsPageLocaleLatestVariant,
        where: v.cms_page_id == ^cms_page.id,
        where: not is_nil(v.cms_page_latest_published_variant_id),
        limit: 1

    repo().exists?(query)
  end

  defp filter_by_status(query, "published") do
    query
    |> join(:inner, [cp], v in CmsPageLocaleLatestVariant, on: v.cms_page_id == cp.id)
    |> where([cp, v], not is_nil(v.cms_page_latest_published_variant_id))
    |> distinct([cp], cp.id)
  end

  defp filter_by_status(query, "draft") do
    published_page_ids =
      from(v in CmsPageLocaleLatestVariant,
        where: not is_nil(v.cms_page_latest_published_variant_id),
        select: v.cms_page_id
      )

    query
    |> where([cp], cp.id not in subquery(published_page_ids))
  end

  @doc """
  Applies sorting to a query based on the given column and order.

  ## Parameters

    * `query` - The Ecto query to sort
    * `sort_by` - Column to sort by: "created", "views", or "status"
    * `sort_order` - Sort direction: "asc" or "desc" (default: "asc")

  ## Examples

      iex> apply_sorting(query, "created", "desc")
      #Ecto.Query<...>

  """
  def apply_sorting(query, sort_by, sort_order) do
    cond do
      sort_by == "created" && sort_order == "desc" ->
        query |> order_by([cp], desc: cp.inserted_at)

      sort_by == "created" ->
        query |> order_by([cp], asc: cp.inserted_at)

      sort_by == "views" && sort_order == "desc" ->
        query |> order_by([cp], desc_nulls_last: cp.views)

      sort_by == "views" ->
        query |> order_by([cp], asc_nulls_first: cp.views)

      sort_by == "status" ->
        sort_by_status(query, sort_order)

      true ->
        query
    end
  end

  defp sort_by_status(query, sort_order) do
    published_page_ids =
      from(v in CmsPageLocaleLatestVariant,
        where: not is_nil(v.cms_page_latest_published_variant_id),
        select: v.cms_page_id
      )

    cond do
      sort_order == "desc" ->
        query
        |> order_by([cp], desc: cp.id in subquery(published_page_ids))

      sort_order == "asc" ->
        query
        |> order_by([cp], asc: cp.id in subquery(published_page_ids))
    end
  end

  @doc """
  Fetches a slice of root pages using offset/limit.
  Used by CmsListing for combined pagination.
  """
  def fetch_pages_slice(query, status, offset, limit, opts \\ [])

  def fetch_pages_slice("", "", offset, limit, opts) do
    CmsPage
    |> where([cp], is_nil(cp.cms_directory_id))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> limit(^limit)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_pages_slice("", status, offset, limit, opts) when status in ["published", "draft"] do
    CmsPage
    |> where([cp], is_nil(cp.cms_directory_id))
    |> filter_by_status(status)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> limit(^limit)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_pages_slice("", _status, offset, limit, opts),
    do: fetch_pages_slice("", "", offset, limit, opts)

  def fetch_pages_slice(query, "", offset, limit, opts) do
    CmsPage
    |> where([cp], is_nil(cp.cms_directory_id))
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> preload(:directory)
    |> with_published_status()
    |> limit(^limit)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_pages_slice(query, status, offset, limit, opts)
      when status in ["published", "draft"] do
    CmsPage
    |> where([cp], is_nil(cp.cms_directory_id))
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> filter_by_status(status)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> preload(:directory)
    |> with_published_status()
    |> limit(^limit)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_pages_slice(query, _status, offset, limit, opts),
    do: fetch_pages_slice(query, "", offset, limit, opts)

  @doc """
  Fetches a slice of directory pages using offset/limit.
  Used by CmsListing for combined pagination.
  """
  def fetch_pages_for_directory_slice(directory_id, query, status, offset, limit, opts \\ [])

  def fetch_pages_for_directory_slice(directory_id, "", "", offset, limit, opts) do
    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> limit(^limit)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_pages_for_directory_slice(directory_id, "", status, offset, limit, opts)
      when status in ["published", "draft"] do
    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> filter_by_status(status)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> limit(^limit)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_pages_for_directory_slice(directory_id, "", _status, offset, limit, opts),
    do: fetch_pages_for_directory_slice(directory_id, "", "", offset, limit, opts)

  def fetch_pages_for_directory_slice(directory_id, query, "", offset, limit, opts) do
    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> limit(^limit)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_pages_for_directory_slice(directory_id, query, status, offset, limit, opts)
      when status in ["published", "draft"] do
    CmsPage
    |> where([cp], cp.cms_directory_id == ^directory_id)
    |> where([cp], ilike(cp.title, ^"%#{query}%"))
    |> filter_by_status(status)
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> with_published_status()
    |> limit(^limit)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_pages_for_directory_slice(directory_id, query, _status, offset, limit, opts),
    do: fetch_pages_for_directory_slice(directory_id, query, "", offset, limit, opts)
end
