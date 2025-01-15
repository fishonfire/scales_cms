defmodule ScalesCmsWeb.Components.CmsComponents.Image.ImageEditor do
  @moduledoc """
  An image components editor
  """
  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper
  alias ScalesCmsWeb.Components.CmsComponents.Image.ImageProperties

  use ScalesCmsWeb, :live_component

  use ScalesCmsWeb.Components.CmsComponents.Helpers.FileUploader,
    entity_name: "image"

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
    |> allow_upload(:image,
      accept: ~w(.png .jpeg .jpg .webp),
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
        component={ScalesCmsWeb.Components.CmsComponents.Image}
      >
        <div class="flex">
          <img
            :if={Map.get(@block.properties || %{}, "image_path", nil) != nil}
            src={
              S3Upload.get_presigned_url_for_display(
                Map.get(@block.properties || %{}, "image_path", nil)
              )
            }
            class="max-w-[200px] max-h-[200px] object-cover mr-[24px]"
          />

          <.file_uploader {assigns} entity_name="image" />
        </div>
      </.live_component>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"image_properties" => properties}, socket) do
    properties = put_file_urls(socket, properties)

    with {:ok, block} <-
           ScalesCms.Cms.CmsPageVariantBlocks.update_cms_page_variant_block(
             socket.assigns.block,
             %{properties: properties}
           ) do
      socket
      |> assign(block: block)
      |> then(&{:noreply, &1})
    end
  end

  def handle_event("save", %{}, socket) do
    {:noreply, socket}
  end
end
