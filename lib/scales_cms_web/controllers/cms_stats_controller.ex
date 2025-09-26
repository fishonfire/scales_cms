defmodule ScalesCmsWeb.CmsStatsController do
  use ScalesCmsWeb, :controller
  alias ScalesCms.Cms.CmsPages

  def index(conn, _params) do
    csv_content =
      CmsPages.list_cms_pages()
      |> CmsPages.preload_directory()
      |> Enum.map(fn p ->
        %{"id" => p.id, "title" => p.title, "views" => p.views, "directory" => directory_title(p)}
      end)
      |> CSV.encode(headers: ["id", "title", "views", "directory"])
      |> Enum.join("")

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", ~s(attachment; filename="report.csv"))
    |> send_resp(200, csv_content)
  end

  defp directory_title(nil), do: ""
  defp directory_title(%{directory: nil}), do: ""
  defp directory_title(page), do: page.directory.title
end
