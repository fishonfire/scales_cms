defmodule GlorioCmsWeb.Api.Public.StructureJSON do
  def index(%{pages: pages, directories: directories, api_version: api_version}) do
    %{
      api_version: api_version,
      pages:
        Enum.map(
          pages,
          &GlorioCmsWeb.Api.Public.PagesJSON.show(%{
            page: &1.latest_published_page,
            api_version: api_version
          })
        ),
      directories:
        Enum.map(directories, &GlorioCmsWeb.Api.Public.DirectoriesJSON.show(%{directory: &1}))
    }
  end
end
