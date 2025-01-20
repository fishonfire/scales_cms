defmodule ScalesCmsWeb.Components.CmsComponents.CTAButton do
  @moduledoc """
  A header component for the CMS
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCmsWeb.Components.CmsComponents.CTAButton.CTAButtonEditor

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: "CTA Button",
    category: "CTA",
    description: "A call to action button with a title, subtitle, and icon",
    icon_type: "cms_cta",
    preview_module: CTAButtonEditor,
    version: "0.0.1"

  def serialize(api_version, block), do: default_serialize(api_version, block)
end
