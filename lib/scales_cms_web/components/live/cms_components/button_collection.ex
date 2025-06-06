defmodule ScalesCmsWeb.Components.CmsComponents.ButtonCollection do
  @moduledoc """
  A button collection component for the CMS
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCmsWeb.Components.CmsComponents.ButtonCollection.ButtonCollectionEditor

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: "Button Collection",
    category: "CTA",
    description: "One ore more buttons",
    icon_type: "cms_button_collection",
    preview_module: ButtonCollectionEditor,
    version: "0.0.1"

  def serialize(api_version, block), do: default_serialize(api_version, block)
end
