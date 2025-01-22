defmodule ScalesCmsWeb.Components.CmsComponents.Lottie do
  @moduledoc """
  An upload to s3 lottie component
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCms.Cms.Helpers.S3Upload

  import ScalesCmsWeb.Components.HelperComponents.DrawerComponents

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: gettext("Lottie"),
    category: "Media",
    description: gettext("Upload a nice lottie"),
    icon_type: "cms_video",
    preview_module: ScalesCmsWeb.Components.CmsComponents.Lottie.LottieEditor,
    version: "0.0.1"

  def serialize(_api_version, block) do
    %{
      id: block.id,
      component_type: block.component_type,
      properties:
        Map.merge(block.properties, %{
          "lottie_url" =>
            S3Upload.get_presigned_url_for_display(
              Map.get(block.properties || %{}, "lottie_path", nil)
            )
        })
    }
  end
end
