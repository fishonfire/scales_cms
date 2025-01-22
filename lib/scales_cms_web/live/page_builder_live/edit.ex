defmodule ScalesCmsWeb.PageBuilderLive.Edit do
  use ScalesCmsWeb, :live_view

  require Logger

  alias ScalesCms.Cms.CmsPageVariants
  alias ScalesCms.Cms.CmsPageVariantBlocks

  alias ScalesCms.Constants.Topics

  import ScalesCmsWeb.Components.CmsComponentsRenderer
  alias ScalesCmsWeb.Components.LocaleSwitcher

  alias ScalesCms.Cms.Flows.Pages.{SelectVersion, Publish, StartVersion}
  alias ScalesCms.Cms.Flows.Blocks.{ReorderBlocks, InsertBlock}

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(ScalesCms.PubSub, Topics.get_block_updated_topic())

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id}, _, socket) do
    with pv <- CmsPageVariants.get_cms_page_variant!(id) do
      socket
      |> assign(:categories, ScalesCmsWeb.Components.CmsComponents.get_categories())
      |> assign(:active_category, "All")
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:cms_page_variant, pv)
      |> assign(:form, to_form(CmsPageVariants.change_cms_page_variant(pv)))
      |> assign(:blocks, CmsPageVariantBlocks.list_blocks_for_page_variant(id))
      |> then(&{:noreply, &1})
    end
  rescue
    Ecto.NoResultsError ->
      socket
      |> put_flash(:error, gettext("Could not find the page"))
      |> redirect(to: ~p"/cms")
      |> then(&{:noreply, &1})
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
        socket
        |> assign(
          :blocks,
          CmsPageVariantBlocks.list_blocks_for_page_variant(socket.assigns.cms_page_variant.id)
        )
        |> then(&{:noreply, &1})

      {:error, _} ->
        Logger.error("Unable to change order of day routes")

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
    type = params["draggedId"]

    with {:ok, _block} <-
           InsertBlock.perform(new_block_index, type, page_variant_id) do
      socket
      |> assign(
        :blocks,
        CmsPageVariantBlocks.list_blocks_for_page_variant(page_variant_id)
      )
      |> then(&{:noreply, &1})
    end
  end

  def handle_event(
        "dropped",
        %{"fromDropzoneId" => "page-drop-zone", "toDropzoneId" => "drawer", "draggedId" => id},
        socket
      ) do
    pv_id = socket.assigns.cms_page_variant.id

    [_, id] = String.split(id, "-")
    {id, _} = Integer.parse(id)

    CmsPageVariantBlocks.get_cms_page_variant_block!(id)
    |> CmsPageVariantBlocks.delete_cms_page_variant_block()

    socket
    |> assign(
      :blocks,
      CmsPageVariantBlocks.list_blocks_for_page_variant(pv_id)
    )
    |> then(&{:noreply, &1})
  end

  def handle_event(
        "dropped",
        %{"fromDropzoneId" => "drawer", "toDropzoneId" => "drawer"},
        socket
      ),
      do: {:noreply, socket}

  def handle_event("delete", %{"id" => id}, socket) do
    CmsPageVariantBlocks.get_cms_page_variant_block!(id)
    |> CmsPageVariantBlocks.delete_cms_page_variant_block()

    socket
    |> assign(
      :blocks,
      CmsPageVariantBlocks.list_blocks_for_page_variant(socket.assigns.cms_page_variant.id)
    )
    |> then(&{:noreply, &1})
  rescue
    Ecto.NoResultsError ->
      socket
      |> assign(
        :blocks,
        CmsPageVariantBlocks.list_blocks_for_page_variant(socket.assigns.cms_page_variant.id)
      )
      |> then(&{:noreply, &1})
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

    socket
    |> assign(
      :blocks,
      CmsPageVariantBlocks.list_blocks_for_page_variant(socket.assigns.cms_page_variant.id)
    )
    |> then(&{:noreply, &1})
  rescue
    Ecto.NoResultsError ->
      socket
      |> assign(
        :blocks,
        CmsPageVariantBlocks.list_blocks_for_page_variant(socket.assigns.cms_page_variant.id)
      )
      |> then(&{:noreply, &1})
  end

  def handle_event("add_embedded", %{"id" => id, "embedded_field" => embedded_field}, socket) do
    CmsPageVariantBlocks.get_cms_page_variant_block!(id)
    |> CmsPageVariantBlocks.add_cms_page_variant_block_embedded_element(embedded_field)

    socket
    |> assign(
      :blocks,
      CmsPageVariantBlocks.list_blocks_for_page_variant(socket.assigns.cms_page_variant.id)
    )
    |> then(&{:noreply, &1})
  rescue
    Ecto.NoResultsError ->
      socket
      |> assign(
        :blocks,
        CmsPageVariantBlocks.list_blocks_for_page_variant(socket.assigns.cms_page_variant.id)
      )
      |> then(&{:noreply, &1})
  end

  def handle_event("start-new-version", _, socket) do
    with {:ok, new_page_variant} <-
           StartVersion.perform(socket.assigns.cms_page_variant) do
      socket
      |> push_navigate(to: ~p"/cms/page_builder/#{new_page_variant.id}")
      |> then(&{:noreply, &1})
    end
  rescue
    _exception ->
      socket
      |> put_flash(:error, gettext("Could not start a new version"))
  end

  def handle_event("publish", _, socket) do
    with {:ok, page_variant} <-
           Publish.perform(socket.assigns.cms_page_variant) do
      socket
      |> assign(:cms_page_variant, page_variant)
      |> put_flash(:info, gettext("Page published"))
      |> then(&{:noreply, &1})
    end
  end

  def handle_event("select-component-category", %{"category" => category}, socket) do
    socket
    |> assign(:active_category, category)
    |> then(&{:noreply, &1})
  end

  @impl Phoenix.LiveView
  def handle_info(
        {:block_updated, %{block_id: _block_id, cms_page_variant_id: cms_page_variant_id}},
        socket
      ) do
    if socket.assigns.cms_page_variant.id == cms_page_variant_id do
      socket
      |> assign(
        :blocks,
        CmsPageVariantBlocks.list_blocks_for_page_variant(socket.assigns.cms_page_variant.id)
      )
      |> then(&{:noreply, &1})
    else
      {:noreply, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_info(
        {_, {:saved, _}},
        socket
      ) do
    socket
    |> assign(
      :blocks,
      CmsPageVariantBlocks.list_blocks_for_page_variant(socket.assigns.cms_page_variant.id)
    )
    |> then(&{:noreply, &1})
  end

  @impl Phoenix.LiveView
  def handle_info(
        {ScalesCmsWeb.Components.LocaleSwitcher, {:locale_switched, locale}},
        %{assigns: %{cms_page_variant: cms_page_variant}} = socket
      ) do
    if socket.assigns.cms_page_variant.locale != locale do
      new_cms_page_variant =
        SelectVersion.perform(cms_page_variant, locale)

      socket
      |> push_navigate(to: ~p"/cms/page_builder/#{new_cms_page_variant.id}")
      |> then(&{:noreply, &1})
    else
      {:noreply, socket}
    end
  end

  def handle_info({ScalesCmsWeb.Components.LocaleSwitcher, {:locale_switched, _locale}}, socket),
    do: {:noreply, socket}

  defp page_title(:edit), do: "Show Cms page"
end
