defmodule ScalesCmsWeb.Components.CmsComponents.Video.VideoEditor do
  @moduledoc """
  An image components editor
  """
  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper
  alias ScalesCmsWeb.Components.CmsComponents.Video.VideoProperties

  use ScalesCmsWeb, :live_component

  use ScalesCmsWeb.Components.CmsComponents.Helpers.FileUploader,
    entity_name: "video"

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
        )
      )

    socket
    |> assign(assigns)
    |> allow_upload(:video,
      accept: ~w(.mp4 .webm),
      max_entries: 1,
      auto_upload: true,
      external: &presign_entry/2
    )
    |> assign(form: form)
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        id={"head-#{@block.id}"}
        module={BlockWrapper}
        block={@block}
        component={ScalesCmsWeb.Components.CmsComponents.Video}
      >
        <div class="flex">
          <%= if has_video(@block.properties) do %>
            <video controls class="max-w-[200px] max-h-[200px] object-cover mr-[24px]">
              <source :if={has_video(@block.properties)} src={get_video_url(@block.properties)} />
            </video>
          <% end %>

          <.file_uploader {assigns} entity_name="video" />
        </div>

        <.simple_form for={@form} phx-submit="store-properties" phx-target={@myself}>
          <.input
            :if={
              Map.get(@block.properties, "video_path", nil) == nil &&
                length(assigns.uploads.video.entries) == 0
            }
            type="text"
            field={@form[:video_url]}
            label="Video url"
          />
          <.input type="text" field={@form[:title]} label="Title" />
          <.input type="text" field={@form[:subtitle]} label="Subtitle" />

          <div class="my-2">
            <.input type="checkbox" field={@form[:autoplay]} label="Autoplay" />
            <.input type="checkbox" field={@form[:controls]} label="Controls" />
            <.input type="checkbox" field={@form[:fullscreen]} label="Fullscreen" />
            <.input type="checkbox" field={@form[:looping]} label="Looping" />
            <.input type="checkbox" field={@form[:mute]} label="Mute" />
          </div>

          <:actions>
            <.button phx-disable-with="Saving..." class="btn-secondary">{gettext("Save")}</.button>
          </:actions>
        </.simple_form>
      </.live_component>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("store-properties", %{"video_properties" => properties}, socket) do
    properties = Map.merge(socket.assigns.block.properties, properties)

    with _block <-
           ScalesCms.Cms.CmsPageVariantBlocks.update_cms_page_variant_block(
             socket.assigns.block,
             %{properties: properties}
           ) do
      {:noreply, socket}
    end
  end

  def handle_event("save", %{"video_properties" => properties}, socket) do
    properties = put_file_urls(socket, properties)

    with {:ok, block} <-
           ScalesCms.Cms.CmsPageVariantBlocks.update_cms_page_variant_block(
             socket.assigns.block,
             %{properties: Map.merge(socket.assigns.block.properties, properties)}
           ) do
      socket
      |> assign(block: block)
      |> then(&{:noreply, &1})
    end
  end

  def handle_event("save", %{}, socket) do
    {:noreply, socket}
  end

  def has_video(block_properties) do
    Map.get(block_properties, "video_path", nil) != nil ||
      Map.get(block_properties, "video_url", nil) != nil
  end

  def get_video_url(block_properties) do
    if Map.get(block_properties, "video_url", nil) != nil do
      Map.get(block_properties, "video_url", nil)
    else
      S3Upload.get_presigned_url_for_display(Map.get(block_properties || %{}, "video_path", nil))
    end
  end
end
