defmodule ScalesCmsWeb.Components.CmsComponents.ButtonCollection do
  @moduledoc """
  A button collection component for the CMS
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCmsWeb.Components.CmsComponents.ButtonCollection.ButtonCollectionEditor
  alias ScalesCms.Cms.Helpers.S3Upload

  use ScalesCmsWeb.Components.HelperComponents.RootComponent,
    title: "Button Collection",
    category: "CTA",
    description: "One ore more buttons",
    icon_type: "cms_button_collection",
    preview_module: ButtonCollectionEditor,
    version: "0.0.1"

  def serialize(_api_version, block) do
    %{
      id: block.id,
      component_type: block.component_type,
      properties: %{
        buttons:
          Enum.map(block.properties.buttons, fn button ->
            %{
              title: button.title,
              subtitle: button.subtitle,
              icon: button.icon,
              page_id: button.page_id,
              payload: button.payload,
              url: button.url,
              image_url: S3Upload.get_presigned_url_for_display(button.image_path),
              image_path: button.image_path
            }
          end)
      }
    }
  end
end
