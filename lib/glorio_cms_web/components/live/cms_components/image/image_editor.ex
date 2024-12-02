defmodule GlorioCmsWeb.Components.CmsComponents.Image.ImageEditor do
  alias GlorioCmsWeb.Components.HelperComponents.BlockWrapper
  alias GlorioCmsWeb.Components.CmsComponents.Image.ImageProperties
  alias GlorioCms.Cms.Helpers.SimpleS3Upload

  use GlorioCmsWeb, :live_component

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    form =
      to_form(
        ImageProperties.changeset(
          struct(
            ImageProperties,
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
  def render(assigns) do
    ~H"""
    <div>
      <.live_component id={"head-#{@block.id}"} module={BlockWrapper} block={@block}>
        <img src={Map.get(@block.properties, "image_url", nil)} />

        <section phx-drop-target={@uploads.image.ref}>
          <.simple_form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
            <.input type="hidden" field={@form[:image_url]} />

            <.live_file_input upload={@uploads.image} target={@myself} />

            <:actions>
              <.button phx-disable-with="Saving...">Save image</.button>
            </:actions>
          </.simple_form>

          <%!-- render each avatar entry --%>
          <%= for entry <- @uploads.image.entries do %>
            <article class="upload-entry">
              <figure>
                <.live_img_preview entry={entry} />
                <figcaption><%= entry.client_name %></figcaption>
              </figure>

              <%!-- entry.progress will update automatically for in-flight entries --%>
              <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>

              <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
              <button
                type="button"
                phx-click="cancel-upload"
                phx-value-ref={entry.ref}
                aria-label="cancel"
              >
                &times;
              </button>

              <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
              <%= for err <- upload_errors(@uploads.image, entry) do %>
                <p class="alert alert-danger"><%= inspect(err) %></p>
              <% end %>
            </article>
          <% end %>

          <%= for err <- upload_errors(@uploads.image) do %>
            <p class="alert alert-danger"><%= inspect(err) %></p>
          <% end %>
        </section>
      </.live_component>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"image_properties" => properties}, socket) do
    properties = put_image_urls(socket, properties)

    IO.inspect(properties)

    with {:ok, block} <-
           GlorioCms.Cms.CmsPageVariantBlocks.update_cms_page_variant_block(
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

  defp put_image_urls(socket, block) do
    uploaded_file_urls =
      consume_uploaded_entries(socket, :image, fn _, entry ->
        {:ok, SimpleS3Upload.entry_url(entry)}
      end)

    %{
      block
      | "image_url" => add_image_url_to_params(List.first(uploaded_file_urls), block["image_url"])
    }
  end

  defp add_image_url_to_params(s3_url, image_url) when is_nil(s3_url), do: image_url
  defp add_image_url_to_params(s3_url, _image_url), do: s3_url

  defp presign_entry(entry, %{assigns: %{uploads: uploads}} = socket) do
    {:ok, SimpleS3Upload.meta(entry, uploads), socket}
  end
end
