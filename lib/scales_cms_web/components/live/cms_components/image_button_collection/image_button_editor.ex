defmodule ScalesCmsWeb.Components.CmsComponents.ImageButtonCollection.ImageButtonEditor do
  @moduledoc false
  use ScalesCmsWeb, :live_component
  alias ScalesCmsWeb.Components.CmsComponents.ImageButton.ImageButtonProperties
  alias ScalesCms.Cms.CmsPageVariantBlocks
  alias ScalesCms.Cms.Helpers.S3Upload

  import ScalesCmsWeb.Components.CmsComponents.Helpers.FileUploaderMultiple

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> allow_upload(
      String.to_atom("image-upload-#{assigns.index}-#{assigns.block.id}"),
      accept: ~w(.png .jpeg .jpg .webp),
      max_entries: 1,
      auto_upload: true,
      external: &presign_entry/2
    )
    |> assign_form(assigns.button)
    |> then(&{:ok, &1})
  end

  defp assign_form(socket, button) do
    form =
      to_form(
        ImageButtonProperties.changeset(
          %ImageButtonProperties{},
          button
        )
      )

    assign(socket, form: form)
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "save",
        %{"image_button_properties" => properties},
        socket
      ) do
    properties = Map.merge(socket.assigns.button, properties)

    properties =
      put_file_urls(
        "image-upload-#{socket.assigns.index}-#{socket.assigns.block.id}",
        "image",
        socket,
        properties
      )

    save(properties, socket.assigns.index, socket)
  end

  def handle_event(
        "store-properties",
        %{"image_button_properties" => properties, "index" => index},
        socket
      ) do
    properties = Map.merge(socket.assigns.button, properties)

    save(properties, String.to_integer(index), socket)
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

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.file_upload_component
        {assigns}
        entity_name={"image-upload-#{@index}-#{@block.id}"}
        target_name="image"
      />

      <.simple_form
        id={"button-form-#{@index}-#{@block.id}"}
        for={@form}
        phx-submit="store-properties"
        phx-target={@myself}
        phx-value-index={@index}
      >
        <.input id={"title-#{@index}-#{@block.id}"} type="text" field={@form[:title]} label="Title" />
        <.input
          id={"subtitle-#{@index}-#{@block.id}"}
          type="text"
          field={@form[:subtitle]}
          label="Subtitle"
        />

        <.label>{gettext("Image")}</.label>
        <%= if Map.get(@block.properties || %{}, "image_path", nil) != nil do %>
          <img
            src={S3Upload.get_presigned_url_for_display(Map.get(@button, "image_path", nil))}
            class="max-w-[200px] max-h-[200px] object-cover mr-[24px]"
          />
        <% end %>

        <.input id={"icon-#{@index}-#{@block.id}"} type="text" field={@form[:icon]} label="Icon" />

        <.live_component
          id={"page-input-#{@block.id}-#{@index}"}
          module={ScalesCmsWeb.Components.HelperComponents.PageSearch}
          field={@form[:page_id]}
          field_id={"page-input-#{@block.id}-#{@index}"}
        />

        <.input id={"url-#{@index}-#{@block.id}"} type="text" field={@form[:url]} label="URL" />
        <.input
          id={"payload-#{@index}-#{@block.id}"}
          type="text"
          field={@form[:payload]}
          label="Payload"
        />
        <:actions>
          <.button phx-disable-with="Saving..." class="btn-secondary">
            {gettext("Save")}
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
