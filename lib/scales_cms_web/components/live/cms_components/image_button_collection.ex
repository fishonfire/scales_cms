defmodule ScalesCmsWeb.Components.CmsComponents.ImageButtonCollection do
  @moduledoc """
  A button collection component for the CMS
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCmsWeb.Components.CmsComponents.ImageButtonCollection.ImageButtonCollectionEditor

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: "Image Button Collection",
    category: "CTA",
    description: "A collection of image buttons",
    icon_type: "cms_image_button_collection",
    preview_module: ImageButtonCollectionEditor,
    version: "0.0.1"

  def serialize(api_version, block), do: default_serialize(api_version, block)
end
