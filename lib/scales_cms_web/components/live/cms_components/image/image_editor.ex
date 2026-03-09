defmodule ScalesCmsWeb.Components.CmsComponents.Image.ImageEditor do
  @moduledoc """
  An image components editor
  """
  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper
  alias ScalesCmsWeb.Components.CmsComponents.Image.ImageProperties
  alias ScalesCmsWeb.CmsMediaLibraryLive.MediaLibraryModal
  alias ScalesCms.Cms.Helpers.S3Upload

  use ScalesCmsWeb, :live_component

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    form =
      to_form(
        ImageProperties.changeset(
          struct(
            ImageProperties,
            assigns.block.properties || %{}
          ),
          assigns.block.properties || %{}
        )
      )

    socket
    |> assign(assigns)
    |> assign(form: form)
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveComponent
  def handle_event("open_media_library", _params, socket) do
    {:noreply,
     push_event(socket, "open-modal", %{
       to: "#media-library-modal-#{socket.assigns.block.id}-modal",
       id: "media-library-modal-#{socket.assigns.block.id}-modal"
     })}
  end

  def handle_event("media_selected", %{"id" => id}, socket) do
    item = ScalesCms.Cms.CmsMediaLibrary.get_media_library_item!(id)

    properties =
      Map.merge(socket.assigns.block.properties || %{}, %{
        "image_path" => item.url,
        "image_url" => S3Upload.get_presigned_url_for_display(item.url)
      })

    with {:ok, block} <-
           ScalesCms.Cms.CmsPageVariantBlocks.update_cms_page_variant_block(
             socket.assigns.block,
             %{properties: properties}
           ) do
      socket
      |> assign(block: block)
      |> push_event("close-modal", %{
        to: "#media-library-modal-#{socket.assigns.block.id}-modal",
        id: "media-library-modal-#{socket.assigns.block.id}-modal"
      })
      |> then(&{:noreply, &1})
    end
  end

  def handle_event("close_media_library", _params, socket) do
    {:noreply,
     push_event(socket, "close-modal", %{
       to: "#media-library-modal-#{socket.assigns.block.id}-modal",
       id: "media-library-modal-#{socket.assigns.block.id}-modal"
     })}
  end
end
