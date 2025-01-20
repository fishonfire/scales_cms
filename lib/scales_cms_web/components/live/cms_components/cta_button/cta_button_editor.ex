defmodule ScalesCmsWeb.Components.CmsComponents.CTAButton.CTAButtonEditor do
  @moduledoc """
  The MD editor, rendering the Trix WYSIWYG editor for the MD component
  """
  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper
  alias ScalesCmsWeb.Components.CmsComponents.CTAButton.CTAButtonProperties
  alias ScalesCms.Constants.Buttons

  use ScalesCmsWeb, :live_component

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    form =
      to_form(
        CTAButtonProperties.changeset(
          struct(
            CTAButtonProperties,
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
  def handle_event("store-properties", %{"cta_button_properties" => properties}, socket) do
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
        component={ScalesCmsWeb.Components.CmsComponents.CTAButton}
      >
        <.simple_form for={@form} phx-submit="store-properties" phx-target={@myself}>
          <.input
            type="select"
            field={@form[:bg_color_variant]}
            options={Buttons.get_button_color_variants()}
            label="Background color"
          />
          <.input type="text" field={@form[:title]} label="Title" />
          <.input type="text" field={@form[:subtitle]} label="Subtitle" />
          <.input type="text" field={@form[:icon]} label="Icon" />

          <.live_component
            id={"page-input-#{@block.id}"}
            module={ScalesCmsWeb.Components.HelperComponents.PageSearch}
            field={@form[:page_id]}
          />

          <.input type="text" field={@form[:url]} label="URL" />
          <.input type="textarea" field={@form[:payload]} label="Payload" />

          <:actions>
            <.button phx-disable-with="Saving..." class="btn-secondary">{gettext("Save")}</.button>
          </:actions>
        </.simple_form>
      </.live_component>
    </div>
    """
  end
end
