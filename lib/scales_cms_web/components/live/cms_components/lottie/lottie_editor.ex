defmodule ScalesCmsWeb.Components.CmsComponents.Lottie.LottieEditor do
  @moduledoc """
  A lottie animation components editor
  """
  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper
  alias ScalesCmsWeb.Components.CmsComponents.Lottie.LottieProperties
  alias ScalesCmsWeb.CmsMediaLibraryLive.MediaLibraryModal
  alias ScalesCms.Cms.Helpers.S3Upload

  use ScalesCmsWeb, :live_component

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    form =
      to_form(
        LottieProperties.changeset(
          %LottieProperties{},
          assigns.block.properties || %{}
        )
      )

    socket
    |> assign(assigns)
    |> assign(form: form)
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveComponent
  def handle_event("store-properties", %{"lottie_properties" => properties}, socket) do
    properties = Map.merge(socket.assigns.block.properties, properties)

    with {:ok, block} <-
           ScalesCms.Cms.CmsPageVariantBlocks.update_cms_page_variant_block(
             socket.assigns.block,
             %{properties: properties}
           ) do
      notify_parent({:saved, block})
      {:noreply, assign(socket, :block, block)}
    end
  end

  def handle_event("open_media_library", _params, socket) do
    modal_id = "media-library-modal-#{socket.assigns.block.id}-modal"

    {:noreply,
     push_event(socket, "open-modal", %{
       to: "##{modal_id}",
       id: modal_id
     })}
  end

  def handle_event("close_media_library", _params, socket) do
    modal_id = "media-library-modal-#{socket.assigns.block.id}-modal"

    {:noreply,
     push_event(socket, "close-modal", %{
       to: "##{modal_id}",
       id: modal_id
     })}
  end

  def handle_event("media_selected", %{"id" => id}, socket) do
    item = ScalesCms.Cms.CmsMediaLibrary.get_media_library_item!(id)

    properties =
      socket.assigns.block.properties
      |> Map.put("lottie_path", item.url)
      |> Map.put("lottie_url", S3Upload.get_presigned_url_for_display(item.url))

    with {:ok, block} <-
           ScalesCms.Cms.CmsPageVariantBlocks.update_cms_page_variant_block(
             socket.assigns.block,
             %{properties: properties}
           ) do
      modal_id = "media-library-modal-#{socket.assigns.block.id}-modal"
      notify_parent({:saved, block})

      socket
      |> assign(:block, block)
      |> push_event("close-modal", %{
        to: "##{modal_id}",
        id: modal_id
      })
      |> then(&{:noreply, &1})
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
