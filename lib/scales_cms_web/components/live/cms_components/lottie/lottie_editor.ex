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
    |> assign_new(:show_media_library, fn -> false end)
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
    {:noreply, assign(socket, :show_media_library, true)}
  end

  def handle_event("close_media_library", _params, socket) do
    {:noreply, assign(socket, :show_media_library, false)}
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
      notify_parent({:saved, block})

      socket
      |> assign(:block, block)
      |> assign(:show_media_library, false)
      |> then(&{:noreply, &1})
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
