defmodule ScalesCmsWeb.Components.CmsComponents.Image do
  @moduledoc """
  An upload to s3 image component
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCms.Cms.Helpers.S3Upload

  import ScalesCmsWeb.Components.HelperComponents.DrawerComponents

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: gettext("Image"),
    category: "Images",
    description: gettext("Upload a nice image"),
    icon_type: "cms_rich_text",
    preview_module: ScalesCmsWeb.Components.CmsComponents.Image.ImageEditor,
    version: "0.0.1"

  def serialize(_api_version, block) do
    %{
      id: block.id,
      component_type: block.component_type,
      properties:
        Map.merge(block.properties, %{
          presigned_url:
            S3Upload.get_presigned_url_for_display(
              Map.get(block.properties || %{}, "image_path", nil)
            )
        })
    }
  end
end
