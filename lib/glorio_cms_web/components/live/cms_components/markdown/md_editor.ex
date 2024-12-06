defmodule GlorioCmsWeb.Components.CmsComponents.Md.MdEditor do
  @moduledoc """
  The MD editor, rendering the Trix WYSIWYG editor for the MD component
  """
  alias GlorioCmsWeb.Components.HelperComponents.BlockWrapper
  alias GlorioCmsWeb.Components.CmsComponents.Md.MdProperties

  use GlorioCmsWeb, :live_component

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    form =
      to_form(
        MdProperties.changeset(
          struct(
            MdProperties,
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

  def handle_event("store-properties", %{"md_properties" => properties}, socket) do
    with _block <-
           GlorioCms.Cms.CmsPageVariantBlocks.update_cms_page_variant_block(
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
      <.live_component id={"head-#{@block.id}"} module={BlockWrapper} block={@block}>
        <div
          id={"markdown-#{@block.id}"}
          phx-hook="Markdown"
          phx-block-id={@block.id}
          class="m-[16px]"
        >
          <trix-toolbar id={"markdown-#{@block.id}-toolbar"} phx-update="ignore"></trix-toolbar>
          <trix-editor
            class="trix-editor"
            id={"markdown-#{@block.id}-editor"}
            toolbar={"markdown-#{@block.id}-toolbar"}
            phx-update="ignore"
          >
          </trix-editor>
        </div>

        <.simple_form for={@form} phx-change="store-properties" phx-target={@myself}>
          <.input type="hidden" field={@form[:content]} id={"markdown-#{@block.id}-content"} />
        </.simple_form>
      </.live_component>
    </div>
    """
  end
end