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

      iex> list_pages_for_directory_id(23)
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
  Returns the list of searched pages.

  ## Examples

      iex> list_pages_for_directory_id("Page title")
      [%CmsPage{}, ...]

  """
  def search_cms_pages(query) do
    CmsPage
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
  Fetches pages with optional query and status filters.
  Used for root-level page listing.

  ## Examples

      iex> fetch_pages("", "")
      [%CmsPage{}, ...]

      iex> fetch_pages("search term", "published")
      [%CmsPage{}, ...]

  """
  def fetch_pages("", ""), do: list_cms_pages()
  def fetch_pages("", status), do: list_cms_pages(status)
  def fetch_pages(query, ""), do: search_cms_pages(query)
  def fetch_pages(query, status), do: search_cms_pages(query, status)

  @doc """
  Fetches pages for a directory with optional query and status filters.

  ## Examples

      iex> fetch_pages_for_directory(123, "", "")
      [%CmsPage{}, ...]

      iex> fetch_pages_for_directory(123, "search term", "published")
      [%CmsPage{}, ...]

  """
  def fetch_pages_for_directory(directory_id, "", ""),
    do: list_pages_for_directory_id(directory_id)

  def fetch_pages_for_directory(directory_id, "", status),
    do: list_pages_for_directory_id(directory_id, status)

  def fetch_pages_for_directory(directory_id, query, ""),
    do: search_cms_pages_for_directory_id(directory_id, query)

  def fetch_pages_for_directory(directory_id, query, status),
    do: search_cms_pages_for_directory_id(directory_id, query, status)

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
end
