defmodule ScalesCmsWeb.Components.CmsComponents.ImageButton do
  @moduledoc """
  A header component for the CMS
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCms.Cms.Helpers.S3Upload

  alias ScalesCmsWeb.Components.CmsComponents.ImageButton.ImageButtonEditor

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: "Image Button",
    category: "CTA",
    description: "A clickable button, with a title and an image",
    icon_type: "cms_cta_image",
    preview_module: ImageButtonEditor,
    version: "0.0.1"

  def serialize(_api_version, block) do
    %{
      id: block.id,
      component_type: block.component_type,
      properties:
        Map.merge(block.properties, %{
          "image_url" =>
            S3Upload.get_presigned_url_for_display(
              Map.get(block.properties || %{}, "image_path", nil)
            )
        })
    }
  end
end
