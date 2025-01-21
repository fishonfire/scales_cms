defmodule ScalesCmsWeb.CmsDirectoryLive.Show do
  use ScalesCmsWeb, :live_view

  alias ScalesCms.Cms.CmsDirectories

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:cms_directory, CmsDirectories.get_cms_directory!(id))}
  end

  defp page_title(:show), do: gettext("Show directory")
  defp page_title(:edit), do: gettext("Edit directory")
end
