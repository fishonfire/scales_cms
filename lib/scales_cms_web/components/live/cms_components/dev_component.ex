defmodule ScalesCmsWeb.Components.CmsComponents.Dev do
  @moduledoc false
  use ScalesCmsWeb, :live_component
  alias ScalesCmsWeb.Components.CmsComponents.Dev.DevEditor
  import ScalesCmsWeb.Components.HelperComponents.DrawerComponents

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: "Development Component",
    category: "Content",
    description: "A test",
    icon_type: "cms_rich_text",
    preview_module: DevEditor,
    version: "0.0.1"

  def serialize(_api_version, block) do
    {:ok, json} = Jason.decode(block.properties["properties"] || "{}")

    %{
      id: block.id,
      component_type: block.properties["component_type"] || block.component_type,
      properties: json
    }
  end
end
