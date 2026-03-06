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

          <button
            type="button"
            phx-click="open_media_library"
            phx-target={@myself}
            class="inline-flex items-center gap-2 px-4 py-2 bg-gray-100 hover:bg-gray-200 dark:bg-gray-700 dark:hover:bg-gray-600 text-gray-700 dark:text-gray-200 rounded-lg transition-colors text-sm"
          >
            <.icon name="hero-film" class="h-4 w-4" />
            {gettext("Select from library")}
          </button>
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

      <.live_component
        :if={@show_media_library}
        id={"media-library-modal-#{@block.id}"}
        module={MediaLibraryModal}
        filter_type="lottie"
        target={@myself}
      />
    </div>
    """
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
