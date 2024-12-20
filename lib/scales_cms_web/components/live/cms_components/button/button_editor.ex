defmodule ScalesCmsWeb.Components.CmsComponents.Button.ButtonEditor do
  @moduledoc """
  The MD editor, rendering the Trix WYSIWYG editor for the MD component
  """
  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper
  alias ScalesCmsWeb.Components.CmsComponents.Button.ButtonProperties

  use ScalesCmsWeb, :live_component

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    form =
      to_form(
        ButtonProperties.changeset(
          struct(
            ButtonProperties,
            assigns.block.properties
          ),
          assigns.block.properties
        )
      )

    socket
    |> assign(assigns)
    |> assign(form: form)
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveComponent
  def handle_event("store-properties", %{"button_properties" => properties}, socket) do
    with _block <-
           ScalesCms.Cms.CmsPageVariantBlocks.update_cms_page_variant_block(
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
        component={ScalesCmsWeb.Components.CmsComponents.Button}
      >
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
