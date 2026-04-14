defmodule ScalesCmsWeb.Components.CmsComponents.Header.HeaderEditor do
  @moduledoc """
  Editor for the header component
  """
  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper
  alias ScalesCmsWeb.Components.CmsComponents.Header.HeaderProperties

  use ScalesCmsWeb, :live_component

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    form =
      to_form(
        HeaderProperties.changeset(
          struct(
            HeaderProperties,
            assigns.block.properties
          ),
          assigns.block.properties
        ),
        id: "header-properties-form-#{assigns.block.id}"
      )

    socket
    |> assign(assigns)
    |> assign(form: form)
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "store-properties",
        %{"header_properties" => properties},
        %{assigns: %{block: %ScalesCms.Cms.CmsPageVariantBlock{}}} = socket
      ) do
    with _block <-
           ScalesCms.Cms.CmsPageVariantBlocks.update_cms_page_variant_block(
             socket.assigns.block,
             %{properties: properties}
           ) do
      {:noreply, socket}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "store-properties",
        %{"header_properties" => properties},
        %{assigns: %{block: %ScalesCms.Cms.CmsBlockTemplate{}}} = socket
      ) do
    with _block <-
           ScalesCms.Cms.CmsBlockTemplates.update_cms_block_template(
             socket.assigns.block,
             %{properties: properties}
           ) do
      {:noreply, socket}
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
        component={ScalesCmsWeb.Components.CmsComponents.Header}
        published={@published}
      >
        <.simple_form for={@form} phx-change="store-properties" phx-target={@myself}>
          <.input
            type="text"
            field={@form[:title]}
            label="Title"
            disabled={@disabled}
            phx-debounce="400"
          />
          <.input
            type="text"
            field={@form[:subtitle]}
            label="Subtitle"
            disabled={@disabled}
            phx-debounce="400"
          />
        </.simple_form>
      </.live_component>
    </div>
    """
  end
end
