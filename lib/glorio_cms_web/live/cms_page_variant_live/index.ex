defmodule GlorioCmsWeb.CmsPageVariantLive.Index do
  use GlorioCmsWeb, :live_view

  alias GlorioCms.Cms.CmsPageVariants
  alias GlorioCms.Cms.CmsPageVariant

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :cms_page_variants, CmsPageVariants.list_cms_page_variants())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Cms page variant")
    |> assign(:cms_page_variant, CmsPageVariants.get_cms_page_variant!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Cms page variant")
    |> assign(:cms_page_variant, %CmsPageVariant{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Cms page variants")
    |> assign(:cms_page_variant, nil)
  end

  @impl true
  def handle_info(
        {GlorioCmsWeb.CmsPageVariantLive.FormComponent, {:saved, cms_page_variant}},
        socket
      ) do
    {:noreply, stream_insert(socket, :cms_page_variants, cms_page_variant)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    cms_page_variant = CmsPageVariants.get_cms_page_variant!(id)
    {:ok, _} = CmsPageVariants.delete_cms_page_variant(cms_page_variant)

    {:noreply, stream_delete(socket, :cms_page_variants, cms_page_variant)}
  end
end
