defmodule ScalesCmsWeb.Components.CmsComponents.ImageButtonCollection.ImageButtonEditor do
  @moduledoc false
  use ScalesCmsWeb, :live_component
  alias ScalesCmsWeb.Components.CmsComponents.ImageButton.ImageButtonProperties
  alias ScalesCms.Cms.CmsPageVariantBlocks
  alias ScalesCms.Cms.Helpers.S3Upload
  alias ScalesCmsWeb.CmsMediaLibraryLive.MediaLibraryModal

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> assign_form(assigns.button)
    |> then(&{:ok, &1})
  end

  defp assign_form(socket, button) do
    form =
      to_form(
        ImageButtonProperties.changeset(
          %ImageButtonProperties{},
          button
        ),
        id: "image_button-properties-form-#{socket.assigns.block.id}-#{socket.assigns.index}"
      )

    assign(socket, form: form)
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "store-properties",
        %{"image_button_properties" => properties, "index" => index},
        socket
      ) do
    properties = Map.merge(socket.assigns.button, properties)

    save(properties, String.to_integer(index), socket)
  end

  def handle_event("media_selected", %{"id" => id}, socket) do
    item = ScalesCms.Cms.CmsMediaLibrary.get_media_library_item!(id)

    properties =
      socket.assigns.button
      |> Map.put("image_path", item.url)
      |> Map.put("image_url", S3Upload.get_presigned_url_for_display(item.url))

    buttons =
      Map.get(socket.assigns.block.properties, "buttons", [])
      |> List.replace_at(socket.assigns.index, properties)

    modal_id = "media-library-modal-#{socket.assigns.block.id}-#{socket.assigns.index}-modal"

    with {:ok, block} <-
           CmsPageVariantBlocks.update_cms_page_variant_block(
             socket.assigns.block,
             %{properties: Map.merge(socket.assigns.block.properties, %{"buttons" => buttons})}
           ) do
      notify_parent({:saved, block})

      socket
      |> close_modal(modal_id)
      |> then(&{:noreply, &1})
    end
  end

  defp save(properties, index, socket) do
    buttons =
      Map.get(socket.assigns.block.properties, "buttons", [])
      |> List.replace_at(index, properties)

    with {:ok, block} <-
           CmsPageVariantBlocks.update_cms_page_variant_block(
             socket.assigns.block,
             %{properties: Map.merge(socket.assigns.block.properties, %{"buttons" => buttons})}
           ) do
      notify_parent({:saved, block})
      {:noreply, socket}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
