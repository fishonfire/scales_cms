defmodule GlorioCmsWeb.PageBuilderLive.Edit do
  use GlorioCmsWeb, :live_view

  alias Ecto.Multi
  alias GlorioCms.Repo
  import Ecto.Query, warn: false

  require Logger

  alias GlorioCms.Cms.CmsPageVariants
  alias GlorioCms.Cms.CmsPageVariantBlocks
  alias GlorioCms.Cms.CmsPageVariantBlock

  import GlorioCmsWeb.Components.CmsComponentsRenderer
  alias GlorioCmsWeb.Components.LocaleSwitcher
  alias GlorioCms.Constants.Topics

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
    case reorder_blocks(new_order) do
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
    table_index = params["newDraggableIndex"]
    # panel_index = params["oldDraggableIndex"]
    type = params["draggedId"]
    pv_id = socket.assigns.cms_page_variant.id

    with {:ok, _result} <-
           Repo.transaction(fn ->
             GlorioCms.Cms.CmsPageVariantBlock
             |> where([pvb], pvb.cms_page_variant_id == ^pv_id and pvb.sort_order >= ^table_index)
             |> update(inc: [sort_order: 1])
             |> Repo.update_all([])
           end) do
      GlorioCms.Cms.CmsPageVariantBlocks.create_cms_page_variant_block(%{
        sort_order: table_index,
        component_type: type,
        cms_page_variant_id: pv_id
      })

      socket
      |> stream(
        :blocks,
        CmsPageVariantBlocks.list_blocks_for_page_variant(pv_id)
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
      case CmsPageVariants.get_latest_cms_page_variant_for_locale(
             cms_page_variant.cms_page_id,
             locale
           ) do
        nil ->
          {:ok, new_cms_page_variant} =
            CmsPageVariants.create_cms_page_variant(%{
              cms_page_id: cms_page_variant.cms_page_id,
              locale: locale,
              version: 1,
              title: cms_page_variant.title
            })

          socket
          |> push_navigate(to: ~p"/cms/cms_page_builder/#{new_cms_page_variant.id}")
          |> then(&{:noreply, &1})

        new_cms_page_variant ->
          socket
          |> push_navigate(to: ~p"/cms/cms_page_builder/#{new_cms_page_variant.id}")
          |> then(&{:noreply, &1})
      end
    else
      {:noreply, socket}
    end
  end

  defp page_title(:edit), do: "Show Cms page"

  def reorder_blocks(new_order) do
    Enum.with_index(new_order)
    |> Enum.reduce(Multi.new(), fn {block_id, new_order}, multi ->
      {block_id, _} = Integer.parse(block_id)

      Multi.update(
        multi,
        {:cms_page_variant_block, block_id},
        CmsPageVariantBlock.change_order_changeset(%CmsPageVariantBlock{id: block_id}, %{
          sort_order: new_order
        })
      )
    end)
    |> Repo.transaction()
  end
end
