defmodule ScalesCmsWeb.Components.CmsComponents.Header do
  @moduledoc """
  A header component for the CMS
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCmsWeb.Components.CmsComponents.Header.HeaderEditor

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: "Header",
    category: "Content",
    description: "Heading and subtitles",
    icon_type: "cms_header",
    preview_module: HeaderEditor,
    version: "0.0.1"

  def serialize(api_version, block), do: default_serialize(api_version, block)
end
