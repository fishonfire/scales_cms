defmodule ScalesCmsWeb.Components.CmsComponents.Video.VideoEditor do
  @moduledoc """
  A video components editor with media library support
  """
  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper
  alias ScalesCmsWeb.Components.CmsComponents.Video.VideoProperties
  alias ScalesCmsWeb.CmsMediaLibraryLive.MediaLibraryModal
  alias ScalesCms.Cms.Helpers.S3Upload

  use ScalesCmsWeb, :live_component

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    form =
      to_form(
        VideoProperties.changeset(
          struct(
            VideoProperties,
            assigns.block.properties || %{}
          ),
          assigns.block.properties || %{}
        ),
        id: "video-properties-form-#{assigns.block.id}"
      )

    socket
    |> assign(assigns)
    |> assign(form: form)
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "media_selected",
        %{"id" => id},
        %{assigns: %{block: %ScalesCms.Cms.CmsPageVariantBlock{}}} = socket
      ) do
    item = ScalesCms.Cms.CmsMediaLibrary.get_media_library_item!(id)

    properties =
      socket.assigns.block.properties
      |> Map.put("video_path", item.url)
      |> Map.put("video_url", nil)

    with {:ok, block} <-
           ScalesCms.Cms.CmsPageVariantBlocks.update_cms_page_variant_block(
             socket.assigns.block,
             %{properties: properties}
           ) do
      socket
      |> assign(block: block)
      |> close_modal("media-library-modal-#{socket.assigns.block.id}-modal")
      |> then(&{:noreply, &1})
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "media_selected",
        %{"id" => id},
        %{assigns: %{block: %ScalesCms.Cms.CmsBlockTemplate{}}} = socket
      ) do
    item = ScalesCms.Cms.CmsMediaLibrary.get_media_library_item!(id)

    properties =
      socket.assigns.block.properties
      |> Map.put("video_path", item.url)
      |> Map.put("video_url", nil)

    with {:ok, block} <-
           ScalesCms.Cms.CmsBlockTemplates.update_cms_block_template(
             socket.assigns.block,
             %{properties: properties}
           ) do
      socket
      |> assign(block: block)
      |> close_modal("media-library-modal-#{socket.assigns.block.id}-modal")
      |> then(&{:noreply, &1})
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "store-properties",
        %{"video_properties" => properties},
        %{assigns: %{block: %ScalesCms.Cms.CmsPageVariantBlock{}}} = socket
      ) do
    properties = Map.merge(socket.assigns.block.properties, properties)

    with {:ok, _block} <-
           ScalesCms.Cms.CmsPageVariantBlocks.update_cms_page_variant_block(
             socket.assigns.block,
             %{properties: properties}
           ) do
      {:noreply, socket}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "store-properties",
        %{"video_properties" => properties},
        %{assigns: %{block: %ScalesCms.Cms.CmsBlockTemplate{}}} = socket
      ) do
    properties = Map.merge(socket.assigns.block.properties, properties)

    with {:ok, _block} <-
           ScalesCms.Cms.CmsBlockTemplates.update_cms_block_template(
             socket.assigns.block,
             %{properties: properties}
           ) do
      {:noreply, socket}
    end
  end

  def has_video(block_properties) do
    Map.get(block_properties, "video_path", nil) != nil ||
      Map.get(block_properties, "video_url", nil) != nil
  end

  defp get_video_url(%{"video_path" => video_path}) when not is_nil(video_path) do
    S3Upload.get_presigned_url_for_display(video_path)
  end

  defp get_video_url(%{"video_url" => video_url}), do: video_url
  defp get_video_url(_), do: nil
end
