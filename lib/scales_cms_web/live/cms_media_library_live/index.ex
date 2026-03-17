defmodule ScalesCmsWeb.CmsMediaLibraryLive.Index do
  use ScalesCmsWeb, :live_view

  alias ScalesCms.Cms.CmsMediaLibraryItem
  alias ScalesCms.Cms.CmsMediaLibrary
  alias ScalesCms.Cms.Helpers.S3Upload
  alias ScalesCmsWeb.CmsMediaLibraryLive.MediaLibraryUtils

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    upload_config = MediaLibraryUtils.upload_config()

    socket =
      socket
      |> assign(:query, "")
      |> assign(:media_type, "")
      |> assign(:media_items, MediaLibraryUtils.list_media_items("", ""))
      |> assign(
        :edit_form,
        to_form(CmsMediaLibrary.change_media_library_item(%CmsMediaLibraryItem{}))
      )
      |> assign(:item_to_delete, nil)
      |> allow_upload(:media,
        accept: MediaLibraryUtils.get_accepted_types(nil),
        max_entries: upload_config.max_entries,
        max_file_size: upload_config.max_file_size,
        auto_upload: true,
        external: &presign_entry/2,
        progress: &handle_progress/3
      )

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _url, socket), do: {:noreply, socket}

  @impl Phoenix.LiveView
  def handle_event("search", %{"query" => query}, socket) do
    media_items = MediaLibraryUtils.list_media_items(query, socket.assigns.media_type)

    {:noreply,
     socket
     |> assign(:query, query)
     |> assign(:media_items, media_items)}
  end

  def handle_event("filter_media_type", %{"media_type" => media_type}, socket) do
    media_items = MediaLibraryUtils.list_media_items(socket.assigns.query, media_type)

    {:noreply,
     socket
     |> assign(:media_type, media_type)
     |> assign(:media_items, media_items)}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :media, ref)}
  end

  # This event is used to trigger the upload process.
  def handle_event("validate", _, socket) do
    {:noreply, socket}
  end

  def handle_event("show_delete_modal", %{"id" => id}, socket) do
    item = CmsMediaLibrary.get_media_library_item!(id)

    {:noreply,
     socket
     |> assign(:item_to_delete, item)
     |> open_modal("delete-media-modal")}
  end

  def handle_event("hide_delete_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:item_to_delete, nil)
     |> close_modal("delete-media-modal")}
  end

  def handle_event("confirm_delete", _params, socket) do
    item = socket.assigns.item_to_delete
    {:ok, _} = CmsMediaLibrary.delete_media_library_item(item)

    media_items =
      MediaLibraryUtils.list_media_items(socket.assigns.query, socket.assigns.media_type)

    {:noreply,
     socket
     |> assign(:media_items, media_items)
     |> assign(:item_to_delete, nil)
     |> close_modal("delete-media-modal")}
  end

  def handle_event("show_edit_modal", %{"id" => id}, socket) do
    item = CmsMediaLibrary.get_media_library_item!(id)

    {:noreply,
     socket
     |> assign(:item_to_edit, item)
     |> assign(:edit_form, to_form(CmsMediaLibrary.change_media_library_item(item)))
     |> open_modal("edit-media-modal")}
  end

  def handle_event("hide_edit_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:item_to_edit, nil)
     |> close_modal("edit-media-modal")}
  end

  def handle_event(
        "save_edit",
        %{"name" => _name} = params,
        socket
      ) do
    item = socket.assigns.item_to_edit

    case CmsMediaLibrary.update_media_library_item(item, params) do
      {:ok, _media_item} ->
        media_items =
          MediaLibraryUtils.list_media_items(socket.assigns.query, socket.assigns.media_type)

        {:noreply,
         socket
         |> assign(:media_items, media_items)
         |> assign(:item_to_edit, nil)
         |> close_modal("edit-media-modal")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:edit_form, to_form(changeset))
         |> open_modal("edit-media-modal")}
    end
  end

  defp handle_progress(:media, entry, socket) do
    if entry.done? do
      uploaded_file =
        consume_uploaded_entry(socket, entry, fn _meta ->
          url = S3Upload.entry_url(entry)
          path = String.replace(url, S3Upload.bucket_path(), "")
          type = MediaLibraryUtils.get_media_type(entry.client_type)
          name = entry.client_name

          {:ok, %{url: url, path: path, type: type, name: name}}
        end)

      CmsMediaLibrary.create_media_library_item(%{
        name: uploaded_file.name,
        type: uploaded_file.type,
        url: uploaded_file.path
      })

      media_items =
        MediaLibraryUtils.list_media_items(socket.assigns.query, socket.assigns.media_type)

      {:noreply, assign(socket, :media_items, media_items)}
    else
      {:noreply, socket}
    end
  end

  defp presign_entry(entry, socket) do
    {:ok, {key, url}} = S3Upload.presigned_url(entry)
    {:ok, %{uploader: "S3", key: key, url: url}, socket}
  end

  # Delegate to shared utilities for template access
  defdelegate upload_error_to_string(error), to: MediaLibraryUtils
  defdelegate type_badge_class(type), to: MediaLibraryUtils
  defdelegate supported_formats_text(filter_type), to: MediaLibraryUtils
end
