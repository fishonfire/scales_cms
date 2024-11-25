defmodule GlorioCmsWeb.CmsPageLive.Show do
  use GlorioCmsWeb, :live_view

  alias GlorioCms.Cms.CmsPages
  alias GlorioCms.Cms.CmsPageVariants

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:cms_page, CmsPages.get_cms_page!(id))
     |> stream(:variants, CmsPageVariants.list_cms_page_variants_for_page(id))
     |> then(&{:noreply, &1})
  end

  defp page_title(:show), do: "Show Cms page"
  defp page_title(:edit), do: "Edit Cms page"
end
