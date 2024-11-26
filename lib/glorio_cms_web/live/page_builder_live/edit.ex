defmodule GlorioCmsWeb.PageBuilderLive.Edit do
  use GlorioCmsWeb, :live_view

  alias GlorioCms.Cms.CmsPageVariants
  alias GlorioCms.Cms.CmsPageVariantBlocks
  alias GlorioCms.Cms.CmsPageVariantBlock
  alias Ecto.Multi
  alias GlorioCms.Repo
  require Logger
  import Ecto.Query, warn: false

  import GlorioCmsWeb.Components.CmsComponentsRenderer

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:cms_page_variant, CmsPageVariants.get_cms_page_variant!(id))
    |> stream(:blocks, CmsPageVariantBlocks.list_blocks_for_page_variant(id))
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event(
        "dropped",
        %{
          "newOrder" => new_order,
          "fromDropzoneId" => "page-drop-zone",
          "toDropzoneId" => "page-drop-zone"
        } = info,
        socket
      ) do
    IO.inspect(info)

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
        %{"fromDropzoneId" => "page-drop-zone", "toDropzoneId" => "drawer", "draggedId" => id} =
          params,
        socket
      ) do
    pv_id = socket.assigns.cms_page_variant.id

    IO.inspect(params)

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

  defp page_title(:edit), do: "Show Cms page"

  def reorder_blocks(new_order) do
    Enum.with_index(new_order)
    |> Enum.reduce(Multi.new(), fn {block_id, new_order}, multi ->
      {block_id, _} = Integer.parse(block_id)

      Multi.update(
        multi,
        {:cms_page_variant_block, block_id},
        CmsPageVariantBlock.change_order_changeset(%CmsPageVariantBlock{id: block_id}, %{
          sort_order: new_order + 1
        })
      )
    end)
    |> Repo.transaction()
  end
end
