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
        ),
        id: "cta-button-properties-form-#{assigns.block.id}"
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
        published={@published}
      >
        <.simple_form for={@form} phx-change="store-properties" phx-target={@myself}>
          <.input
            type="select"
            field={@form[:bg_color_variant]}
            options={Buttons.get_button_color_variants()}
            label="Background color"
            disabled={@published}
          />
          <.input
            type="text"
            field={@form[:title]}
            label="Title"
            disabled={@published}
            phx-debounce="400"
          />
          <.input
            type="text"
            field={@form[:subtitle]}
            label="Subtitle"
            disabled={@published}
            phx-debounce="400"
          />
          <.input
            type="text"
            field={@form[:icon]}
            label="Icon"
            disabled={@published}
            phx-debounce="400"
          />

          <.live_component
            id={"page-input-#{@block.id}"}
            module={ScalesCmsWeb.Components.HelperComponents.PageSearch}
            field={@form[:page_id]}
            disabled={@published}
          />

          <.input
            type="text"
            field={@form[:url]}
            label="URL"
            disabled={@published}
            phx-debounce="400"
          />
          <.input
            type="textarea"
            field={@form[:payload]}
            label="Payload"
            disabled={@published}
            phx-debounce="400"
          />
        </.simple_form>
      </.live_component>
    </div>
    """
  end
end
