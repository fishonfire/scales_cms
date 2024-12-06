defmodule GlorioCmsWeb.PageBuilderLive.Edit do
  alias GlorioCms.Cms.Flows.PublishingFlows
  use GlorioCmsWeb, :live_view

  require Logger

  alias GlorioCms.Cms.CmsPageVariants
  alias GlorioCms.Cms.CmsPageVariantBlocks

  alias GlorioCms.Constants.Topics
  alias GlorioCms.Cms.Flows.BlocksFlows

  import GlorioCmsWeb.Components.CmsComponentsRenderer
  alias GlorioCmsWeb.Components.LocaleSwitcher

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(GlorioCms.PubSub, Topics.get_set_locale_topic())

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    pv = CmsPageVariants.get_cms_page_variant!(id)

    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:cms_page_variant, pv)
    |> assign(:form, to_form(CmsPageVariants.change_cms_page_variant(pv)))
    |> stream(:blocks, CmsPageVariantBlocks.list_blocks_for_page_variant(id))
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
    case BlocksFlows.reorder_blocks(new_order) do
      {:ok, _} ->
        socket
        |> stream(
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
           BlocksFlows.insert_block(new_block_index, type, page_variant_id) do
      socket
      |> stream(
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
    |> stream(
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
    |> stream(
      :blocks,
      CmsPageVariantBlocks.list_blocks_for_page_variant(socket.assigns.cms_page_variant.id),
      reset: true
    )
    |> then(&{:noreply, &1})
  rescue
    Ecto.NoResultsError ->
      socket
      |> stream(
        :blocks,
        CmsPageVariantBlocks.list_blocks_for_page_variant(socket.assigns.cms_page_variant.id)
      )
      |> then(&{:noreply, &1})
  end

  def handle_event("start-new-version", _, socket) do
    with {:ok, new_page_variant} <-
           GlorioCms.Cms.Flows.PublishingFlows.start_new_version(socket.assigns.cms_page_variant) do
      socket
      |> push_navigate(to: ~p"/cms/cms_page_builder/#{new_page_variant.id}")
      |> then(&{:noreply, &1})
    end
  rescue
    _exception ->
      socket
      |> put_flash(:error, gettext("Could not start a new version"))
  end

  def handle_event("publish", _, socket) do
    with {:ok, page_variant} <-
           GlorioCms.Cms.Flows.PublishingFlows.publish(socket.assigns.cms_page_variant) do
      socket
      |> assign(:cms_page_variant, page_variant)
      |> put_flash(:info, gettext("Page published"))
      |> then(&{:noreply, &1})
    end
  end

  @impl Phoenix.LiveView
  def handle_info(
        {:set_locale, _locale},
        %{assigns: %{cms_page_variant: nil}} = socket
      ),
      do: {:noreply, socket}

  def handle_info(
        {:set_locale, locale},
        %{assigns: %{cms_page_variant: cms_page_variant}} = socket
      ) do
    if socket.assigns.cms_page_variant.locale != locale do
      new_cms_page_variant =
        PublishingFlows.select_version_based_on_locale(cms_page_variant, locale)

      socket
      |> push_navigate(to: ~p"/cms/cms_page_builder/#{new_cms_page_variant.id}")
      |> then(&{:noreply, &1})
    else
      {:noreply, socket}
    end
  end

  defp page_title(:edit), do: "Show Cms page"
end
