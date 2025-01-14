defmodule ScalesCmsWeb.Components.CmsComponents.ButtonCollection.ButtonCollectionEditor do
  @moduledoc """
  The button collection editor component for the CMS
  """
  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper
  alias ScalesCmsWeb.Components.CmsComponents.ButtonCollection.ButtonCollectionWrapper
  alias ScalesCmsWeb.Components.CmsComponents.Button.ButtonProperties
  alias ScalesCmsWeb.Components.CmsComponents.ButtonCollection.ButtonCollectionProperties
  alias ScalesCms.Cms.CmsPageVariantBlocks
  alias ScalesCms.Constants.Buttons

  use ScalesCmsWeb, :live_component

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> assign_form(assigns.block)
    |> assign_forms(assigns.block)
    |> then(&{:ok, &1})
  end

  defp assign_form(socket, block) do
    form =
      to_form(
        ButtonCollectionProperties.changeset(
          %ButtonCollectionProperties{},
          block.properties
        )
      )

    assign(socket, form: form)
  end

  defp assign_forms(socket, block) do
    forms =
      Enum.map(Map.get(block.properties, "buttons", []), fn value ->
        to_form(
          ButtonProperties.changeset(
            %ButtonProperties{},
            value
          )
        )
      end)

    assign(socket, forms: forms)
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "store-properties",
        %{"button_properties" => properties, "index" => index},
        socket
      ) do
    buttons =
      Map.get(socket.assigns.block.properties, "buttons", [])
      |> List.replace_at(String.to_integer(index), properties)

    with {:ok, block} <-
           CmsPageVariantBlocks.update_cms_page_variant_block(
             socket.assigns.block,
             %{properties: Map.merge(socket.assigns.block.properties, %{"buttons" => buttons})}
           ) do
      {:noreply, socket |> assign_forms(block) |> assign(block: block)}
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("add-button", _, socket) do
    with {:ok, block} <-
           CmsPageVariantBlocks.add_cms_page_variant_block_embedded_element(
             socket.assigns.block,
             "buttons"
           ) do
      {:noreply, socket |> assign_forms(block) |> assign(block: block)}
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
        component={ScalesCmsWeb.Components.CmsComponents.ButtonCollection}
      >
        <%= for {button, index} <- Enum.with_index(@forms || [] ) do %>
          <.live_component
            id={"button-#{@block.id}-#{index}"}
            embedded_index={index}
            module={ButtonCollectionWrapper}
            block={@block}
            component={ScalesCmsWeb.Components.CmsComponents.Button}
            title={button[:title].value || "#{gettext("Button")} #{index + 1}"}
          >
            <.simple_form
              for={button}
              phx-submit="store-properties"
              phx-target={@myself}
              phx-value-index={index}
            >
              <.input
                type="select"
                field={button[:bg_color_variant]}
                options={Buttons.get_button_color_variants()}
                label="Background color"
              />
              <.input id={"title-#{index}"} type="text" field={button[:title]} label="Title" />

              <.live_component
                id={"page-input-#{@block.id}"}
                module={ScalesCmsWeb.Components.HelperComponents.PageSearch}
                field={@form[:page_id]}
              />

              <.input id={"url-#{index}"} type="text" field={button[:url]} label="URL" />
              <.input id={"payload-#{index}"} type="text" field={button[:payload]} label="Payload" />
              <:actions>
                <.button phx-disable-with="Saving...">{gettext("Save")}</.button>
              </:actions>
            </.simple_form>
          </.live_component>
        <% end %>

        <.simple_form for={@form} phx-submit="add-button" phx-target={@myself}>
          <:actions>
            <.button phx-disable-with="Adding...">{gettext("Add button")}</.button>
          </:actions>
        </.simple_form>
      </.live_component>
    </div>
    """
  end
end
