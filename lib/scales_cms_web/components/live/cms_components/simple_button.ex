defmodule ScalesCmsWeb.Components.CmsComponents.SimpleButton do
  @moduledoc """
  A header component for the CMS
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCmsWeb.Components.CmsComponents.SimpleButton.SimpleButtonEditor

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: "Simple Button",
    category: "CTA",
    description: "A clickable button, with a title only",
    icon_type: "cms_rich_text",
    preview_module: SimpleButtonEditor,
    version: "0.0.1"

  def serialize(api_version, block), do: default_serialize(api_version, block)
end
