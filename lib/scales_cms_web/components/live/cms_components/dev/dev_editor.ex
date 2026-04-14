defmodule ScalesCmsWeb.Components.CmsComponents.Dev.DevEditor do
  @moduledoc """
  The MD editor, rendering the Trix WYSIWYG editor for the MD component
  """
  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper
  alias ScalesCmsWeb.Components.CmsComponents.Dev.DevProperties

  use ScalesCmsWeb, :live_component

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    form =
      to_form(
        DevProperties.changeset(
          struct(
            DevProperties,
            assigns.block.properties
          ),
          assigns.block.properties
        ),
        id: "dev-properties-form-#{assigns.block.id}"
      )

    socket
    |> assign(assigns)
    |> assign(form: form)
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "store-properties",
        %{"dev_properties" => properties},
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
        %{"dev_properties" => properties},
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
        component={ScalesCmsWeb.Components.CmsComponents.Dev}
        published={@published}
      >
        <.simple_form for={@form} phx-change="store-properties" phx-target={@myself}>
          <.input
            type="text"
            field={@form[:component_type]}
            label="Custom component name"
            disabled={@disabled}
          />

          <.input
            type="textarea"
            field={@form[:properties]}
            label="Properties payload"
            disabled={@disabled}
          />

          <:actions>
            <.button :if={!@published} phx-disable-with="Saving..." class="btn-secondary">
              {gettext("Save")}
            </.button>
          </:actions>
        </.simple_form>
      </.live_component>
    </div>
    """
  end
end
