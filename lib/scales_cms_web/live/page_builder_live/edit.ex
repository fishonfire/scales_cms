defmodule ScalesCmsWeb.PageBuilderLive.Edit do
  use ScalesCmsWeb, :live_view

  require Logger

  alias ScalesCms.Cms.CmsPageVariants
  alias ScalesCms.Cms.CmsPageVariantBlocks
  alias ScalesCms.Constants.Topics

  import ScalesCmsWeb.Components.HelperComponents.DrawerComponents
  import ScalesCmsWeb.Components.CmsComponentsRenderer
  alias ScalesCmsWeb.Components.LocaleSwitcher

  alias ScalesCms.Cms.Flows.Pages.{SelectVersion, Publish, StartVersion}
  alias ScalesCms.Cms.Flows.Blocks.{ReorderBlocks, InsertBlock}

  @all_category "All"

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(ScalesCms.PubSub, Topics.get_block_updated_topic())

    {:ok,
     socket
     |> assign(:drawer_open, true)
     |> assign(:categories, [@all_category])
     |> assign(:active_category, @all_category)
     |> assign(deleting_block_ids: MapSet.new())
     |> assign(inserted_block_id: nil)
     |> assign(ghost_height: 0)}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _, socket) do
    with pv <- CmsPageVariants.get_cms_page_variant!(id) do
      {:noreply,
       socket
       |> assign_page_variant(pv)
       |> assign(:page_title, page_title(socket.assigns.live_action))
       |> assign(:form, to_form(CmsPageVariants.change_cms_page_variant(pv)))
       |> reload_blocks()}
    end
  rescue
    Ecto.NoResultsError ->
      {:noreply,
       socket
       |> put_flash(:error, gettext("Could not find the page"))
       |> redirect(to: ~p"/cms")}
  end

  @impl Phoenix.LiveView
  def handle_event(
        "dropped",
        %{
          "newOrder" => new_order,
          "fromDropzoneId" => "page-drop-zone",
          "toDropzoneId" => "page-drop-zone"
        },
        socket
      ) do
    case ReorderBlocks.perform(new_order) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(:inserted_block_id, nil)
         |> reload_blocks()}

      {:error, _} ->
        Logger.error("Unable to change order of blocks")
        {:noreply, socket}
    end
  end

  def handle_event(
        "dropped",
        %{"fromDropzoneId" => "drawer", "toDropzoneId" => "page-drop-zone"} = params,
        socket
      ) do
    new_block_index = params["newDraggableIndex"]
    page_variant_id = socket.assigns.cms_page_variant.id
    dragged_id = params["draggedId"]
    ghost_height = params["ghostHeight"]

    case InsertBlock.perform(new_block_index, dragged_id, page_variant_id) do
      {:ok, block} ->
        {:noreply,
         socket
         |> reload_blocks()
         |> assign(:inserted_block_id, block.id)
         |> assign(:ghost_height, ghost_height)}

      {:error, :template_not_found} ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("Template could not be found"))
         |> assign(:inserted_block_id, nil)}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("Could not insert block"))
         |> assign(:inserted_block_id, nil)}
    end
  end

  def handle_event(
        "dropped",
        %{"fromDropzoneId" => "page-drop-zone", "toDropzoneId" => "drawer", "draggedId" => id},
        socket
      ) do
    [_, id] = String.split(id, "-")
    {id, _} = Integer.parse(id)

    CmsPageVariantBlocks.get_cms_page_variant_block!(id)
    |> CmsPageVariantBlocks.delete_cms_page_variant_block()

    {:noreply,
     socket
     |> assign(:inserted_block_id, nil)
     |> reload_blocks()}
  end

  def handle_event(
        "dropped",
        %{"fromDropzoneId" => "drawer", "toDropzoneId" => "drawer"},
        socket
      ) do
    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    id = String.to_integer(id)
    Process.send_after(self(), {:commit_delete, id}, 260)

    {:noreply,
     socket
     |> update(:deleting_block_ids, &MapSet.put(&1, id))
     |> assign(:inserted_block_id, nil)}
  end

  def handle_event("toggle-drawer", _, socket) do
    {:noreply, update(socket, :drawer_open, &(!&1))}
  end

  def handle_event(
        "delete_embedded",
        %{"id" => id, "embedded_field" => embedded_field, "embedded_index" => embedded_index},
        socket
      ) do
    CmsPageVariantBlocks.get_cms_page_variant_block!(id)
    |> CmsPageVariantBlocks.delete_cms_page_variant_block_embedded_element(
      embedded_field,
      embedded_index
    )

    {:noreply,
     socket
     |> assign(:inserted_block_id, nil)
     |> reload_blocks()}
  rescue
    Ecto.NoResultsError ->
      {:noreply, reload_blocks(socket)}
  end

  def handle_event("add_embedded", %{"id" => id, "embedded_field" => embedded_field}, socket) do
    CmsPageVariantBlocks.get_cms_page_variant_block!(id)
    |> CmsPageVariantBlocks.add_cms_page_variant_block_embedded_element(embedded_field)

    {:noreply,
     socket
     |> assign(:inserted_block_id, nil)
     |> reload_blocks()}
  rescue
    Ecto.NoResultsError ->
      {:noreply, reload_blocks(socket)}
  end

  def handle_event("start-new-version", _, socket), do: {:noreply, start_new_version(socket)}

  def handle_event("publish", _, socket) do
    with {:ok, page_variant} <- Publish.perform(socket.assigns.cms_page_variant) do
      {:noreply,
       socket
       |> assign(:cms_page_variant, page_variant)
       |> put_flash(:info, gettext("Page published"))
       |> start_new_version()}
    end
  end

  def handle_event("select-component-category", %{"category" => category}, socket) do
    {:noreply, assign(socket, :active_category, category)}
  end

  def handle_event("update-page", %{"cms_page_variant" => cms_page_variant_params}, socket) do
    with {:ok, page_variant} <-
           CmsPageVariants.update_cms_page_variant(
             socket.assigns.cms_page_variant,
             cms_page_variant_params
           ) do
      {:noreply,
       socket
       |> assign_page_variant(page_variant)
       |> assign(:form, to_form(CmsPageVariants.change_cms_page_variant(page_variant)))
       |> put_flash(:info, gettext("Page edited"))
       |> push_patch(to: ~p"/cms/page_builder/#{page_variant.id}")}
    end
  end

  @impl Phoenix.LiveView
  def handle_info(
        {:block_updated, %{block_id: _block_id, cms_page_variant_id: cms_page_variant_id}},
        socket
      ) do
    if socket.assigns.cms_page_variant.id == cms_page_variant_id do
      {:noreply,
       socket
       |> reload_blocks()
       |> assign(:inserted_block_id, nil)}
    else
      {:noreply, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_info({_, {:saved, _}}, socket) do
    {:noreply,
     socket
     |> reload_blocks()
     |> assign(:inserted_block_id, nil)}
  end

  def handle_info({:commit_delete, id}, socket) do
    CmsPageVariantBlocks.get_cms_page_variant_block!(id)
    |> CmsPageVariantBlocks.delete_cms_page_variant_block()

    {:noreply,
     socket
     |> reload_blocks()
     |> assign(:inserted_block_id, nil)
     |> update(:deleting_block_ids, &MapSet.delete(&1, id))}
  rescue
    Ecto.NoResultsError ->
      {:noreply, reload_blocks(socket)}
  end

  @impl Phoenix.LiveView
  def handle_info(
        {LocaleSwitcher, {:locale_switched, locale}},
        %{assigns: %{cms_page_variant: cms_page_variant}} = socket
      ) do
    if cms_page_variant.locale != locale do
      new_cms_page_variant = SelectVersion.perform(cms_page_variant, locale)

      {:noreply, push_navigate(socket, to: ~p"/cms/page_builder/#{new_cms_page_variant.id}")}
    else
      {:noreply, socket}
    end
  end

  def handle_info({LocaleSwitcher, {:locale_switched, _locale}}, socket), do: {:noreply, socket}

  defp page_title(:edit), do: gettext("Show page")
  defp page_title(:edit_variant), do: gettext("Edit page")

  defp start_new_version(socket) do
    with {:ok, page_variant} <- StartVersion.perform(socket.assigns.cms_page_variant) do
      push_patch(socket, to: ~p"/cms/page_builder/#{page_variant.id}")
    end
  rescue
    _exception ->
      socket
  end

  defp reload_blocks(socket) do
    assign(
      socket,
      :blocks,
      CmsPageVariantBlocks.list_blocks_for_page_variant(socket.assigns.cms_page_variant.id)
    )
  end

  defp assign_page_variant(socket, page_variant) do
    categories = ScalesCmsWeb.Components.CmsComponents.get_categories(page_variant.locale)

    active_category =
      if socket.assigns[:active_category] in categories do
        socket.assigns.active_category
      else
        @all_category
      end

    socket
    |> assign(:cms_page_variant, page_variant)
    |> assign(:categories, categories)
    |> assign(:active_category, active_category)
  end
end
