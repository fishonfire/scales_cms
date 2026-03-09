defmodule ScalesCmsWeb.CmsPageLive.Index do
  use ScalesCmsWeb, :live_view

  alias ScalesCms.Cms.CmsPages

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :cms_pages, CmsPages.list_cms_pages())}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("List pages"))
  end

  @impl Phoenix.LiveView
  def handle_info({ScalesCmsWeb.CmsPageLive.FormComponent, {:saved, cms_page}}, socket) do
    url =
      if is_nil(cms_page.cms_directory_id),
        do: ~p"/cms/directories",
        else: ~p"/cms/directories/#{cms_page.cms_directory_id}"

    socket
    |> push_navigate(to: url)
    |> then(&{:noreply, &1})
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    cms_page = CmsPages.get_cms_page!(id)
    {:ok, _} = CmsPages.delete_cms_page(cms_page)

    {:noreply, stream_delete(socket, :cms_pages, cms_page)}
  end
end
