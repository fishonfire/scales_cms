defmodule ScalesCmsWeb.Components.CmsComponents.Image do
  @moduledoc """
  An upload to s3 image component
  """
  use ScalesCmsWeb, :live_component

  import ScalesCmsWeb.Components.HelperComponents.DrawerComponents

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: gettext("Image"),
    category: "Images",
    description: gettext("Upload a nice image"),
    icon_type: "cms_rich_text",
    preview_module: ScalesCmsWeb.Components.CmsComponents.Image.ImageEditor,
    version: "0.0.1"

  def serialize(api_version, block), do: default_serialize(api_version, block)
end
