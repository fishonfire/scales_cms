defmodule ScalesCmsWeb.CmsDirectoryLive.Index do
  use ScalesCmsWeb, :live_view

  alias ScalesCms.Cms.CmsDirectories
  alias ScalesCms.Cms.CmsPages

  alias ScalesCmsWeb.Components.LocaleSwitcher
  alias ScalesCmsWeb.Helpers.CmsDirectory, as: CmsDirectoryHelper

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket
    |> assign(locale: ScalesCms.Cms.Helpers.Locales.default_locale())
    |> assign(:cms_directories, [])
    |> assign(:cms_pages, [])
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket),
    do: {:noreply, apply_action(socket, socket.assigns.live_action, params)}

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, gettext("Edit directory"))
    |> assign(:cms_directory, CmsDirectories.get_cms_directory!(id))
    |> assign(:cms_page, nil)
    |> assign(:current_directory, nil)
    |> assign(:cms_directories, [])
    |> assign(:cms_pages, [])
    |> assign(:query, "")
    |> assign(:status, "")
    |> assign(:sort_by, "")
    |> assign(:sort_order, "asc")
    |> open_modal("cms_directory-modal")
  end

  defp apply_action(socket, :new, %{"id" => id}) do
    socket
    |> assign(:page_title, gettext("New directory"))
    |> assign(:cms_directory, %ScalesCms.Cms.CmsDirectory{cms_directory_id: id})
    |> assign(:cms_page, nil)
    |> assign(:current_directory, nil)
    |> assign(:cms_directories, [])
    |> assign(:cms_pages, [])
    |> assign(:query, "")
    |> assign(:status, "")
    |> assign(:sort_by, "")
    |> assign(:sort_order, "asc")
    |> open_modal("cms_directory-modal")
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("New directory"))
    |> assign(:cms_directory, %ScalesCms.Cms.CmsDirectory{})
    |> assign(:cms_page, nil)
    |> assign(:current_directory, nil)
    |> assign(:cms_directories, [])
    |> assign(:cms_pages, [])
    |> assign(:query, "")
    |> assign(:status, "")
    |> assign(:sort_by, "")
    |> assign(:sort_order, "asc")
    |> open_modal("cms_directory-modal")
  end

  defp apply_action(socket, :index, %{"id" => id} = params) do
    query = Map.get(params, "query", "")
    status = Map.get(params, "status", "")
    sort_by = Map.get(params, "sort_by", "")
    sort_order = Map.get(params, "sort_order", "asc")
    current_directory = CmsDirectories.get_cms_directory!(id)

    sort_opts = [sort_by: sort_by, sort_order: sort_order]
    cms_directories = CmsDirectories.fetch_directories_for_parent(id, query, sort_opts)
    cms_pages = CmsPages.fetch_pages_for_directory(id, query, status, sort_opts)

    socket
    |> assign(:cms_directories, cms_directories)
    |> assign(:cms_pages, cms_pages)
    |> assign(:current_directory, current_directory)
    |> assign(:page_title, gettext("Directories"))
    |> assign(:cms_directory, nil)
    |> assign(:cms_page, nil)
    |> assign(:query, query)
    |> assign(:status, status)
    |> assign(:sort_by, sort_by)
    |> assign(:sort_order, sort_order)
  end

  defp apply_action(socket, :index, params) do
    query = Map.get(params, "query", "")
    status = Map.get(params, "status", "")
    sort_by = Map.get(params, "sort_by", "")
    sort_order = Map.get(params, "sort_order", "asc")

    sort_opts = [sort_by: sort_by, sort_order: sort_order]
    cms_directories = CmsDirectories.fetch_directories(query, sort_opts)
    cms_pages = CmsPages.fetch_pages(query, status, sort_opts)

    socket
    |> assign(:cms_directories, cms_directories)
    |> assign(:cms_pages, cms_pages)
    |> assign(:current_directory, nil)
    |> assign(:page_title, gettext("Directories"))
    |> assign(:cms_directory, nil)
    |> assign(:cms_page, nil)
    |> assign(:query, query)
    |> assign(:status, status)
    |> assign(:sort_by, sort_by)
    |> assign(:sort_order, sort_order)
  end

  @impl Phoenix.LiveView
  def handle_info({ScalesCmsWeb.CmsDirectoryLive.FormComponent, {:saved, cms_directory}}, socket) do
    cms_directories =
      if cms_directory.cms_directory_id != nil,
        do: CmsDirectories.list_cms_directories_for_parent_id(cms_directory.cms_directory_id),
        else: CmsDirectories.list_cms_directories()

    socket
    |> assign(:cms_directories, cms_directories)
    |> close_modal("cms_directory-modal")
    |> then(&{:noreply, &1})
  end

  def handle_info({ScalesCmsWeb.CmsPageLive.FormComponent, {:saved, cms_page}}, socket) do
    url =
      if is_nil(cms_page.cms_directory_id),
        do: ~p"/cms/directories",
        else: ~p"/cms/directories/#{cms_page.cms_directory_id}"

    socket
    |> close_modal("cms_page-modal")
    |> push_navigate(to: url)
    |> then(&{:noreply, &1})
  end

  @impl Phoenix.LiveView
  def handle_info({ScalesCmsWeb.Components.LocaleSwitcher, {:locale_switched, locale}}, socket) do
    socket
    |> assign(:locale, locale)
    |> then(&{:noreply, &1})
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    cms_directory = CmsDirectories.get_cms_directory!(id)
    {:ok, _} = CmsDirectories.delete_cms_directory(cms_directory)

    cms_directories =
      if cms_directory.cms_directory_id != nil,
        do: CmsDirectories.list_cms_directories_for_parent_id(cms_directory.cms_directory_id),
        else: CmsDirectories.list_cms_directories()

    socket
    |> assign(
      :cms_directories,
      cms_directories
    )
    |> then(&{:noreply, &1})
  rescue
    Ecto.ConstraintError ->
      {:noreply,
       socket
       |> put_flash(:error, "Directory not empty")}
  end

  def handle_event("delete-page", %{"id" => id}, socket) do
    ScalesCms.Cms.Flows.Pages.DeletePage.perform(id)

    cms_pages =
      if socket.assigns.current_directory != nil,
        do: CmsPages.list_pages_for_directory_id(socket.assigns.current_directory.id),
        else: CmsPages.list_cms_pages()

    socket
    |> assign(
      :cms_pages,
      cms_pages
    )
    |> then(&{:noreply, &1})
  rescue
    Ecto.ConstraintError ->
      {:noreply,
       socket
       |> put_flash(:error, "Page not empty")}
  end

  def handle_event("open-directory", %{"id" => id}, socket) do
    socket
    |> push_navigate(to: ~p"/cms/directories/#{id}")
    |> then(&{:noreply, &1})
  end

  def handle_event("open-directory", %{}, socket) do
    socket
    |> push_navigate(to: ~p"/cms/directories")
    |> then(&{:noreply, &1})
  end

  def handle_event("open-page", %{"id" => id}, %{assigns: %{locale: locale}} = socket) do
    pv = ScalesCms.Cms.Flows.Pages.FindCorrectVariant.perform(id, locale)

    socket
    |> push_navigate(to: ~p"/cms/page_builder/#{pv.id}")
    |> then(&{:noreply, &1})
  end

  def handle_event("search", %{"query" => query}, socket) do
    status = socket.assigns.status
    sort_by = socket.assigns.sort_by
    sort_order = socket.assigns.sort_order
    cms_directory = socket.assigns.current_directory

    socket
    |> push_patch(
      to:
        CmsDirectoryHelper.build_filter_path(
          cms_directory,
          query,
          status,
          sort_by,
          sort_order
        )
    )
    |> then(&{:noreply, &1})
  end

  def handle_event("filter_status", %{"status" => status}, socket) do
    query = socket.assigns.query
    sort_by = socket.assigns.sort_by
    sort_order = socket.assigns.sort_order

    socket
    |> push_patch(
      to:
        CmsDirectoryHelper.build_filter_path(
          socket.assigns.current_directory,
          query,
          status,
          sort_by,
          sort_order
        )
    )
    |> then(&{:noreply, &1})
  end

  def handle_event("sort", %{"column" => column}, socket) do
    query = socket.assigns.query
    status = socket.assigns.status
    current_sort_by = socket.assigns.sort_by
    current_sort_order = socket.assigns.sort_order

    {new_sort_by, new_sort_order} =
      cond do
        current_sort_by == column && current_sort_order == "asc" ->
          {column, "desc"}

        current_sort_by == column && current_sort_order == "desc" ->
          {"", "asc"}

        true ->
          {column, "asc"}
      end

    socket
    |> push_patch(
      to:
        CmsDirectoryHelper.build_filter_path(
          socket.assigns.current_directory,
          query,
          status,
          new_sort_by,
          new_sort_order
        )
    )
    |> then(&{:noreply, &1})
  end
end
