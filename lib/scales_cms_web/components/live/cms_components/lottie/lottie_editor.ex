defmodule ScalesCmsWeb.Components.CmsComponents.Lottie.LottieEditor do
  @moduledoc """
  An image components editor
  """
  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper
  alias ScalesCmsWeb.Components.CmsComponents.Lottie.LottieProperties

  use ScalesCmsWeb, :live_component

  use ScalesCmsWeb.Components.CmsComponents.Helpers.FileUploader,
    entity_name: "lottie"

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
    |> allow_upload(:lottie,
      accept: ~w(.json),
      max_entries: 1,
      auto_upload: true,
      external: &presign_entry/2
    )
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
      {:noreply, socket}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"lottie_properties" => properties}, socket) do
    properties = put_file_urls(socket, properties)

    with {:ok, block} <-
           ScalesCms.Cms.CmsPageVariantBlocks.update_cms_page_variant_block(
             socket.assigns.block,
             %{properties: Map.merge(socket.assigns.block.properties, properties)}
           ) do
      notify_parent({:saved, block})
      {:noreply, socket}
    end
  end

  def handle_event("save", %{}, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        id={"head-#{@block.id}"}
        module={BlockWrapper}
        block={@block}
        component={ScalesCmsWeb.Components.CmsComponents.Lottie}
      >
        <div class="flex">
          <script
            src="https://unpkg.com/@dotlottie/player-component@2.7.12/dist/dotlottie-player.mjs"
            type="module"
          >
          </script>

          <%= if Map.get(@block.properties || %{}, "lottie_path", nil) != nil do %>
            <dotlottie-player
              src={
                S3Upload.get_presigned_url_for_display(
                  Map.get(@block.properties || %{}, "lottie_path", nil)
                )
              }
              background="transparent"
              speed="1"
              style="width: 300px; height: 300px"
              class="max-w-[200px] max-h-[200px] object-cover mr-[24px]"
              direction="1"
              playMode="normal"
              loop
              controls
              autoplay
            >
            </dotlottie-player>
          <% end %>

          <.file_uploader {assigns} entity_name="lottie" />
        </div>

        <.simple_form for={@form} phx-submit="store-properties" phx-target={@myself}>
          <.input type="text" field={@form[:title]} label="Title" />
          <.input type="text" field={@form[:subtitle]} label="Subtitle" />

          <div class="my-2">
            <.input type="checkbox" field={@form[:autoplay]} label="Autoplay" />
            <.input type="checkbox" field={@form[:looping]} label="Looping" />
          </div>

          <:actions>
            <.button phx-disable-with="Saving..." class="btn-secondary">{gettext("Save")}</.button>
          </:actions>
        </.simple_form>
      </.live_component>
    </div>
    """
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
