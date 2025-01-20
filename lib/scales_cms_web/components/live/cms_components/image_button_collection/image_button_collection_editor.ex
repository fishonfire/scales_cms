defmodule ScalesCmsWeb.Components.CmsComponents.ImageButtonCollection.ImageButtonCollectionEditor do
  @moduledoc """
  The image button collection editor component for the CMS
  """
  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper
  alias ScalesCmsWeb.Components.CmsComponents.ButtonCollection.ButtonCollectionWrapper
  alias ScalesCmsWeb.Components.CmsComponents.ImageButton.ImageButtonProperties

  alias ScalesCmsWeb.Components.CmsComponents.ImageButtonCollection.ImageButtonCollectionProperties

  alias ScalesCms.Cms.CmsPageVariantBlocks

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
        ImageButtonCollectionProperties.changeset(
          %ImageButtonCollectionProperties{},
          block.properties
        )
      )

    assign(socket, form: form)
  end

  defp assign_forms(socket, block) do
    forms =
      Enum.map(Map.get(block.properties, "buttons", []), fn value ->
        to_form(
          ImageButtonProperties.changeset(
            %ImageButtonProperties{},
            value
          )
        )
      end)

    assign(socket, forms: forms)
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "store-properties",
        %{"image_button_properties" => properties, "index" => index},
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
        component={ScalesCmsWeb.Components.CmsComponents.ImageButtonCollection}
      >
        <%= for {button, index} <- Enum.with_index(@forms || [] ) do %>
          <.live_component
            id={"button-#{@block.id}-#{index}"}
            embedded_index={index}
            module={ButtonCollectionWrapper}
            block={@block}
            component={ScalesCmsWeb.Components.CmsComponents.ImageButton}
            title={button[:title].value || "#{gettext("Button")} #{index + 1}"}
          >
            <.simple_form
              for={button}
              phx-submit="store-properties"
              phx-target={@myself}
              phx-value-index={index}
            >
              <.input id={"title-#{index}"} type="text" field={button[:title]} label="Title" />
              <.input id={"subtitle-#{index}"} type="text" field={button[:subtitle]} label="Subtitle" />
              <.input
                id={"image_url-#{index}"}
                type="text"
                field={button[:image_url]}
                label="Image URL"
              />
              <.input id={"icon-#{index}"} type="text" field={button[:icon]} label="Icon" />

              <.live_component
                id={"page-input-#{@block.id}-#{index}"}
                module={ScalesCmsWeb.Components.HelperComponents.PageSearch}
                field={button[:page_id]}
              />

              <.input id={"url-#{index}"} type="text" field={button[:url]} label="URL" />
              <.input id={"payload-#{index}"} type="text" field={button[:payload]} label="Payload" />
              <:actions>
                <.button phx-disable-with="Saving..." class="btn-secondary">
                  {gettext("Save")}
                </.button>
              </:actions>
            </.simple_form>
          </.live_component>
        <% end %>

        <.simple_form for={@form} phx-submit="add-button" phx-target={@myself}>
          <:actions>
            <.button phx-disable-with="Adding..." class="btn-primary">
              {gettext("Add button")}
            </.button>
          </:actions>
        </.simple_form>
      </.live_component>
    </div>
    """
  end
end
