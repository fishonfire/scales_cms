defmodule GlorioCmsWeb.CmsPageLive.Show do
  use GlorioCmsWeb, :live_view

  alias GlorioCms.Cms.CmsPages

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:cms_page, CmsPages.get_cms_page!(id))}
  end

  defp page_title(:show), do: "Show Cms page"
  defp page_title(:edit), do: "Edit Cms page"
end
