defmodule GlorioCmsWeb.Components.CmsComponents.Image do
  @moduledoc """
  An upload to s3 image component
  """
  use GlorioCmsWeb, :live_component

  import GlorioCmsWeb.Components.HelperComponents.DrawerComponents

  use GlorioCmsWeb.Components.HelperComponents.RootComponent,
    title: gettext("Image"),
    category: "Content",
    description: gettext("Upload a nice image"),
    icon_type: "cms_rich_text",
    preview_module: GlorioCmsWeb.Components.CmsComponents.Image.ImageEditor,
    version: "0.0.1"
end
