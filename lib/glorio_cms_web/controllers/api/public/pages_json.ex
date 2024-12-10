defmodule GlorioCmsWeb.Api.Public.PagesJSON do
  def index(%{pages: pages, api_version: api_version, pagination: pagination}) do
    %{
      api_version: api_version,
      pagination: pagination,
      pages:
        Enum.map(
          pages,
          &GlorioCmsWeb.Api.Public.PagesJSON.show(%{
            page: &1.latest_published_page,
            api_version: api_version
          })
        )
    }
  end

  def show(%{page: page, api_version: api_version}) do
    %{
      id: page.id,
      api_version: api_version,
      title: page.title,
      slug: page.page.slug,
      directory_id: page.page.cms_directory_id,
      locale: page.locale,
      blocks: for(block <- page.blocks, do: block(%{block: block, api_version: api_version}))
    }
  end

  def block(%{block: block, api_version: api_version}) do
    component = GlorioCmsWeb.Components.CmsComponents.get_component(block.component_type)

    component.serialize(
      api_version,
      block
    )
  end
end
