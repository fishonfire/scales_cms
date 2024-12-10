defmodule GlorioCmsWeb.Api.Public.PagesJSON do
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
