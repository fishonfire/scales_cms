defmodule ScalesCmsWeb.CmsPageVariantLive.Show do
  use ScalesCmsWeb, :live_view

  alias ScalesCms.Cms.CmsPageVariants

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:cms_page_variant, CmsPageVariants.get_cms_page_variant!(id))}
  end

  defp page_title(:show), do: "Show Cms page variant"
  defp page_title(:edit), do: "Edit Cms page variant"
end
