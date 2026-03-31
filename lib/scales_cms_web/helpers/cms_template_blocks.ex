defmodule ScalesCmsWeb.Helpers.CmsBlockTemplates do
  @moduledoc """
  Helper functions for building CMS template blocks paths and URLs.
  """

  use ScalesCmsWeb, :verified_routes

  @doc """
  Builds a filter path for the CMS block_templates listing with optional query parameters.

  ## Parameters

    * `current_block_templates` - The current block_templates struct or nil for root
    * `query` - Search query string
    * `sort_by` - Column to sort by ("created", "updated", or "")
    * `sort_order` - Sort direction ("asc" or "desc")
    * `page` - Current page number (optional)
    * `per_page` - Items per page (optional)

  ## Examples

      iex> build_filter_path(nil, "", "", "", "asc")
      "/cms/block_templates"

      iex> build_filter_path(nil, "search", "created", "desc")
      "/cms/block_templates?query=search&sort_by=created&sort_order=desc"

      iex> build_filter_path(nil, "", "", "", "asc", 2, 20)
      "/cms/block_templates?page=2&per_page=20"

  """
  def build_filter_path(
        query,
        sort_by,
        sort_order,
        page \\ nil,
        per_page \\ nil
      ) do
    base_path = ~p"/cms/block_templates"

    params =
      %{}
      |> maybe_add_param("query", query)
      |> maybe_add_param("sort_by", sort_by)
      |> maybe_add_param("sort_order", if(sort_by != "", do: sort_order, else: ""))
      |> maybe_add_pagination_param("page", page)
      |> maybe_add_pagination_param("per_page", per_page)

    if params == %{},
      do: base_path,
      else: base_path <> "?" <> URI.encode_query(params)
  end

  defp maybe_add_param(params, _key, ""), do: params
  defp maybe_add_param(params, _key, nil), do: params
  defp maybe_add_param(params, key, value), do: Map.put(params, key, value)

  defp maybe_add_pagination_param(params, _key, nil), do: params
  defp maybe_add_pagination_param(params, _key, 1), do: params
  defp maybe_add_pagination_param(params, "per_page", 20), do: params
  defp maybe_add_pagination_param(params, key, value), do: Map.put(params, key, value)
end
