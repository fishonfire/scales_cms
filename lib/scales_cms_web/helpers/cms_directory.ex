defmodule ScalesCmsWeb.Helpers.CmsDirectory do
  @moduledoc """
  Helper functions for building CMS directory paths and URLs.
  """

  use ScalesCmsWeb, :verified_routes

  @doc """
  Builds a filter path for the CMS directory listing with optional query parameters.

  ## Parameters

    * `current_directory` - The current directory struct or nil for root
    * `query` - Search query string
    * `status` - Status filter ("published", "draft", or "")
    * `sort_by` - Column to sort by ("created", "views", "status", or "")
    * `sort_order` - Sort direction ("asc" or "desc")

  ## Examples

      iex> build_filter_path(nil, "", "", "", "asc")
      "/cms/directories"

      iex> build_filter_path(nil, "search", "published", "created", "desc")
      "/cms/directories?query=search&status=published&sort_by=created&sort_order=desc"

  """
  def build_filter_path(current_directory, query, status, sort_by, sort_order) do
    base_path =
      if current_directory != nil,
        do: ~p"/cms/directories/#{current_directory.id}",
        else: ~p"/cms/directories"

    params =
      %{}
      |> maybe_add_param("query", query)
      |> maybe_add_param("status", status)
      |> maybe_add_param("sort_by", sort_by)
      |> maybe_add_param("sort_order", if(sort_by != "", do: sort_order, else: ""))

    if params == %{},
      do: base_path,
      else: base_path <> "?" <> URI.encode_query(params)
  end

  defp maybe_add_param(params, _key, ""), do: params
  defp maybe_add_param(params, _key, nil), do: params
  defp maybe_add_param(params, key, value), do: Map.put(params, key, value)
end
