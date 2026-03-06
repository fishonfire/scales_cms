defmodule ScalesCmsWeb.Components.CmsComponents.Image.ImageEditor do
  @moduledoc """
  An image components editor
  """
  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper
  alias ScalesCmsWeb.Components.CmsComponents.Image.ImageProperties
  alias ScalesCmsWeb.CmsMediaLibraryLive.MediaLibraryModal
  alias ScalesCms.Cms.Helpers.S3Upload

  use ScalesCmsWeb, :live_component

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
    |> assign_new(:show_media_library, fn -> false end)
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
        published={@published}
      >
        <div class="flex items-start gap-4">
          <img
            :if={Map.get(@block.properties || %{}, "image_path", nil) != nil}
            src={
              S3Upload.get_presigned_url_for_display(
                Map.get(@block.properties || %{}, "image_path", nil)
              )
            }
            class="max-w-[200px] max-h-[200px] object-cover rounded-lg"
          />

          <button
            :if={!@published}
            type="button"
            phx-click="open_media_library"
            phx-target={@myself}
            class="inline-flex items-center gap-2 px-4 py-2 bg-gray-100 hover:bg-gray-200 dark:bg-gray-700 dark:hover:bg-gray-600 text-gray-700 dark:text-gray-200 rounded-lg transition-colors text-sm"
          >
            <.icon name="hero-photo" class="h-4 w-4" />
            {gettext("Select from library")}
          </button>
        </div>

        <.live_component
          :if={@show_media_library}
          module={MediaLibraryModal}
          id={"media-library-modal-#{@block.id}"}
          filter_type="image"
          target={@myself}
        />
      </.live_component>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("open_media_library", _params, socket) do
    {:noreply, assign(socket, :show_media_library, true)}
  end

  def handle_event("media_selected", %{"id" => id}, socket) do
    item = ScalesCms.Cms.CmsMediaLibrary.get_media_library_item!(id)

    properties =
      Map.merge(socket.assigns.block.properties || %{}, %{
        "image_path" => item.url,
        "image_url" => S3Upload.get_presigned_url_for_display(item.url)
      })

    with {:ok, block} <-
           ScalesCms.Cms.CmsPageVariantBlocks.update_cms_page_variant_block(
             socket.assigns.block,
             %{properties: properties}
           ) do
      socket
      |> assign(block: block)
      |> assign(show_media_library: false)
      |> then(&{:noreply, &1})
    end
  end

  def handle_event("close_media_library", _params, socket) do
    {:noreply, assign(socket, :show_media_library, false)}
  end
end
