defmodule ScalesCmsWeb.Components.CmsComponents.Md.MdEditor do
  @moduledoc """
  The MD editor, rendering the TipTap WYSIWYG editor for the MD component
  """
  alias ScalesCmsWeb.Components.HelperComponents.BlockWrapper
  alias ScalesCmsWeb.Components.CmsComponents.Md.{MdProperties, MdToolbar}

  use ScalesCmsWeb, :live_component

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
        ),
        id: "md-properties-form-#{assigns.block.id}"
      )

    socket
    |> assign(assigns)
    |> assign(form: form)
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "store-properties",
        %{"md_properties" => properties},
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
        %{"md_properties" => properties},
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
        component={ScalesCmsWeb.Components.CmsComponents.Md}
        published={@published}
      >
        <div
          id={"markdown-#{@block.id}"}
          phx-hook="Markdown"
          data-input-id={"markdown-#{@block.id}-content"}
          data-disabled={to_string(@disabled)}
          phx-block-id={@block.id}
          class="m-[4px]"
        >
          <MdToolbar.render id={"markdown-#{@block.id}-toolbar"} />
          <div
            data-markdown-editor
            class="tiptap-editor"
            id={"markdown-#{@block.id}-editor"}
            phx-update="ignore"
          >
          </div>
        </div>

        <.simple_form for={@form} phx-change="store-properties" phx-target={@myself}>
          <.input
            type="textarea"
            phx-debounce="400"
            class="hidden"
            field={@form[:content]}
            id={"markdown-#{@block.id}-content"}
          />
        </.simple_form>
      </.live_component>
    </div>
    """
  end
end
