defmodule ScalesCmsWeb.Components.CmsComponents.Video do
  @moduledoc """
  An upload to s3 video component
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCms.Cms.Helpers.S3Upload

  import ScalesCmsWeb.Components.HelperComponents.DrawerComponents

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: gettext("Video"),
    category: "Media",
    description: gettext("Upload a nice video"),
    icon_type: "cms_video",
    preview_module: ScalesCmsWeb.Components.CmsComponents.Video.VideoEditor,
    version: "0.0.1"

  def serialize(_api_version, block) do
    %{
      id: block.id,
      component_type: block.component_type,
      properties:
        Map.merge(block.properties, %{
          "video_url" =>
            S3Upload.get_presigned_url_for_display(
              Map.get(block.properties || %{}, "video_path", nil)
            )
        })
    }
  end
end
