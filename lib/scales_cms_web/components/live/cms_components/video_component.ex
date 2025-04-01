defmodule ScalesCmsWeb.Components.CmsComponents.Video do
  @moduledoc """
  An upload to s3 video component
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCms.Cms.Helpers.S3Upload
  alias ScalesCmsWeb.Components.CmsComponents.Video.VideoProperties

  import ScalesCmsWeb.Components.HelperComponents.DrawerComponents

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: gettext("Video"),
    category: "Media",
    description: gettext("Upload a nice video"),
    icon_type: "cms_video",
    preview_module: ScalesCmsWeb.Components.CmsComponents.Video.VideoEditor,
    version: "0.0.1"

  def serialize(_api_version, block) do
    raw_properties =
      Map.put(block.properties, "video_url", get_video_url(block.properties))

    # Cast using the embedded schema
    casted_properties =
      %VideoProperties{}
      |> VideoProperties.changeset(raw_properties)
      |> Ecto.Changeset.apply_changes()
      |> Map.from_struct()

    # No need to show null value ID
    casted_properties = Map.delete(casted_properties, :id)

    %{
      id: block.id,
      component_type: block.component_type,
      properties: casted_properties
    }
  end

  defp get_video_url(block_properties) do
    if Map.get(block_properties, "video_path", nil) != nil do
      S3Upload.get_presigned_url_for_display(Map.get(block_properties || %{}, "video_path", nil))
    else
      Map.get(block_properties, "video_url", nil)
    end
  end
end
