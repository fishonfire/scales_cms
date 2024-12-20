defmodule ScalesCmsWeb.Components.CmsComponents.Button do
  @moduledoc """
  A header component for the CMS
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCmsWeb.Components.CmsComponents.Button.ButtonEditor

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: "Button",
    category: "CTA",
    description: "A clickable button with a title, subtitle, and icon",
    icon_type: "cms_rich_text",
    preview_module: ButtonEditor,
    version: "0.0.1"

  def serialize(api_version, block), do: default_serialize(api_version, block)
end
