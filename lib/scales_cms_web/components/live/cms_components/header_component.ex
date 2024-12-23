defmodule ScalesCmsWeb.Components.CmsComponents.Header do
  @moduledoc """
  A header component for the CMS
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCmsWeb.Components.CmsComponents.Header.HeaderEditor

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: "Header",
    category: "Content",
    description: "A nice header",
    icon_type: "cms_rich_text",
    preview_module: HeaderEditor,
    version: "0.0.1"

  def serialize(api_version, block), do: default_serialize(api_version, block)
end
