defmodule ScalesCmsWeb.Components.CmsComponents.ImageButtonCollection.ImageButtonCollectionEditor do
  @moduledoc """
  The image button collection editor component for the CMS
  """
  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper
  alias ScalesCmsWeb.Components.CmsComponents.ButtonCollection.ButtonCollectionWrapper

  alias ScalesCmsWeb.Components.CmsComponents.ImageButtonCollection.{
    ImageButtonEditor,
    ImageButtonCollectionProperties
  }

  alias ScalesCms.Cms.CmsPageVariantBlocks

  use ScalesCmsWeb, :live_component

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> assign_form(assigns.block)
    |> assign(buttons: Map.get(assigns.block.properties, "buttons", []))
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
      socket
      |> assign(buttons: Map.get(block.properties, "buttons", []))
      |> assign(block: block)
      |> then(&{:noreply, &1})
    end
  end

  @impl Phoenix.LiveComponent
  def handle_event("add-button", _, socket) do
    with {:ok, block} <-
           CmsPageVariantBlocks.add_cms_page_variant_block_embedded_element(
             socket.assigns.block,
             "buttons"
           ) do
      socket
      |> assign(buttons: Map.get(block.properties, "buttons", []))
      |> assign(block: block)
      |> then(&{:noreply, &1})
    end
  end
end
