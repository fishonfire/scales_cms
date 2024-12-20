defmodule ScalesCmsWeb.Components.CmsComponents.ImageButton do
  @moduledoc """
  A header component for the CMS
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCmsWeb.Components.CmsComponents.ImageButton.ImageButtonEditor

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: "Image Button",
    category: "CTA",
    description: "A clickable button, with a title and an image",
    icon_type: "cms_rich_text",
    preview_module: ImageButtonEditor,
    version: "0.0.1"

  def serialize(api_version, block), do: default_serialize(api_version, block)
end
