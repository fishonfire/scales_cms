defmodule ScalesCms.Cms.CmsListing do
  @moduledoc """
  Combined CMS listing for directory index screens.

  This context paginates directories and pages as a single list while keeping
  the UX rule that directories always appear before pages.

  """

  alias ScalesCms.Cms.CmsDirectories
  alias ScalesCms.Cms.CmsPages

  @type scope :: :root | {:directory, term()}

  @doc """
  Fetches a combined paginated list of directories and pages.

  Directories are always returned first, followed by pages.

  ## Examples

      iex> fetch_items(:root, "", "", page: 1, per_page: 20)
      [%{type: :directory, data: %CmsDirectory{}}, %{type: :page, data: %CmsPage{}}]

      iex> fetch_items({:directory, 123}, "blog", "published", page: 2, per_page: 10)
      [%{type: :page, data: %CmsPage{}}]
  """
  def fetch_items(scope, query, status, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)
    sort_opts = Keyword.take(opts, [:sort_by, :sort_order])

    start_offset = max(page - 1, 0) * per_page

    dir_count = count_directories(scope, query)

    {dir_offset, dir_limit, page_offset, page_limit} =
      split_offsets(start_offset, per_page, dir_count)

    directories =
      scope
      |> fetch_directories(query, dir_offset, dir_limit, sort_opts)
      |> Enum.map(&%{type: :directory, data: &1})

    pages =
      scope
      |> fetch_pages(query, status, page_offset, page_limit, sort_opts)
      |> Enum.map(&%{type: :page, data: &1})

    directories ++ pages
  end

  @doc """
  Counts the total number of items in the combined listing.
  """
  def count_items(scope, query, status) do
    count_directories(scope, query) + count_pages(scope, query, status)
  end

  defp split_offsets(start_offset, per_page, dir_count) do
    cond do
      per_page <= 0 ->
        {0, 0, 0, 0}

      start_offset < dir_count ->
        dir_offset = start_offset
        dir_limit = min(per_page, dir_count - dir_offset)
        page_offset = 0
        page_limit = per_page - dir_limit
        {dir_offset, dir_limit, page_offset, page_limit}

      true ->
        dir_offset = 0
        dir_limit = 0
        page_offset = start_offset - dir_count
        page_limit = per_page
        {dir_offset, dir_limit, page_offset, page_limit}
    end
  end

  defp count_directories(:root, query), do: CmsDirectories.count_directories(query)

  defp count_directories({:directory, parent_id}, query),
    do: CmsDirectories.count_directories_for_parent(parent_id, query)

  defp count_pages(:root, query, status), do: CmsPages.count_pages(query, status)

  defp count_pages({:directory, directory_id}, query, status),
    do: CmsPages.count_pages_for_directory(directory_id, query, status)

  defp fetch_directories(_scope, _query, _offset, 0, _opts), do: []

  defp fetch_directories(:root, query, offset, limit, opts),
    do: CmsDirectories.fetch_directories_slice(query, offset, limit, opts)

  defp fetch_directories({:directory, parent_id}, query, offset, limit, opts),
    do: CmsDirectories.fetch_directories_for_parent_slice(parent_id, query, offset, limit, opts)

  defp fetch_pages(_scope, _query, _status, _offset, 0, _opts), do: []

  defp fetch_pages(:root, query, status, offset, limit, opts),
    do: CmsPages.fetch_pages_slice(query, status, offset, limit, opts)

  defp fetch_pages({:directory, directory_id}, query, status, offset, limit, opts),
    do: CmsPages.fetch_pages_for_directory_slice(directory_id, query, status, offset, limit, opts)
end
