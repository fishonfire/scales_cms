defmodule ScalesCmsWeb.CmsMediaLibraryLive.MediaLibraryModal do
  @moduledoc """
  A modal live component for selecting or uploading media files.
  Can be embedded in editors to pick existing media or upload new files.
  """
  use ScalesCmsWeb, :live_component

  alias ScalesCms.Cms.CmsMediaLibrary
  alias ScalesCms.Cms.Helpers.S3Upload
  alias ScalesCmsWeb.CmsMediaLibraryLive.MediaLibraryUtils

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok,
     socket
     |> assign(:query, "")
     |> assign(:media_type, "")
     |> assign(:filter_type, nil)
     |> assign(:media_items, [])
     |> assign(:target, nil)}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    filter_type = Map.get(assigns, :filter_type, nil)

    media_type =
      if filter_type do
        filter_type
      else
        socket.assigns[:media_type] || ""
      end

    accept = MediaLibraryUtils.get_accepted_types(filter_type)
    query = socket.assigns[:query] || ""
    media_items = MediaLibraryUtils.list_media_items(query, media_type)
    target = Map.get(assigns, :target, nil)
    upload_config = MediaLibraryUtils.upload_config()

    socket =
      socket
      |> assign(assigns)
      |> assign(:filter_type, filter_type)
      |> assign(:media_type, media_type)
      |> assign(:media_items, media_items)
      |> assign(:target, target)
      |> allow_upload(:media,
        accept: accept,
        max_entries: upload_config.max_entries,
        max_file_size: upload_config.max_file_size,
        auto_upload: true,
        external: &presign_entry/2,
        progress: &handle_progress/3
      )

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
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

  def handle_event("close_modal", _params, socket) do
    send(self(), {__MODULE__, :modal_closed})
    {:noreply, socket}
  end

  # Private functions

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
  defdelegate supported_formats_text(filter_type), to: MediaLibraryUtils
  defdelegate upload_error_to_string(error), to: MediaLibraryUtils
  defdelegate type_badge_class(type), to: MediaLibraryUtils
end
