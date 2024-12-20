defmodule ScalesCmsWeb.Components.CmsComponents.ImageButton.ImageButtonEditor do
  @moduledoc """
  The MD editor, rendering the Trix WYSIWYG editor for the MD component
  """
  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper
  alias ScalesCmsWeb.Components.CmsComponents.ImageButton.ImageButtonProperties

  use ScalesCmsWeb, :live_component

  use ScalesCmsWeb.Components.CmsComponents.Helpers.FileUploader,
    entity_name: "image"

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    form =
      to_form(
        ImageButtonProperties.changeset(
          struct(
            ImageButtonProperties,
            assigns.block.properties
          ),
          assigns.block.properties
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
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("store-properties", %{"image_button_properties" => properties}, socket) do
    properties = Map.merge(socket.assigns.block.properties, properties)

    with _block <-
           ScalesCms.Cms.CmsPageVariantBlocks.update_cms_page_variant_block(
             socket.assigns.block,
             %{properties: properties}
           ) do
      {:noreply, socket}
    end
  end

  def handle_event("save", %{"image_button_properties" => properties}, socket) do
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

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        id={"head-#{@block.id}"}
        module={BlockWrapper}
        block={@block}
        component={ScalesCmsWeb.Components.CmsComponents.ImageButton}
      >
        <img src={
          S3Upload.get_presigned_url_for_display(Map.get(@block.properties || %{}, "image_path", nil))
        } />

        <.file_uploader {assigns} />

        <.simple_form for={@form} phx-submit="store-properties" phx-target={@myself}>
          <.input type="text" field={@form[:title]} label="Title" />
          <.input type="text" field={@form[:subtitle]} label="Subtitle" />
          <.input type="text" field={@form[:icon]} label="Icon" />

          <.input type="text" field={@form[:page_id]} label="Page ID" />
          <.input type="text" field={@form[:url]} label="URL" />
          <.input type="textarea" field={@form[:payload]} label="Payload" />

          <:actions>
            <.button phx-disable-with="Saving...">{gettext("Save")}</.button>
          </:actions>
        </.simple_form>
      </.live_component>
    </div>
    """
  end
end
