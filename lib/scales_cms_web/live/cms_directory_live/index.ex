defmodule ScalesCmsWeb.CmsDirectoryLive.Index do
  use ScalesCmsWeb, :live_view

  alias ScalesCms.Cms.CmsDirectories
  alias ScalesCms.Cms.CmsListing

  alias ScalesCmsWeb.Components.LocaleSwitcher
  alias ScalesCmsWeb.Components.Live.HelperComponents.PaginationComponent
  alias ScalesCmsWeb.Helpers.CmsDirectory, as: CmsDirectoryHelper

  @default_per_page 20

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket
    |> assign(locale: ScalesCms.Cms.Helpers.Locales.default_locale())
    |> assign(:items, [])
    |> assign(:cms_directories, [])
    |> assign(:cms_pages, [])
    |> assign(:current_directory, nil)
    |> assign(:edit_directory, nil)
    |> assign(:new_directory, nil)
    |> assign(:page, 1)
    |> assign(:per_page, @default_per_page)
    |> assign(:total_count, 0)
    |> assign(:max_page, 0)
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"id" => id} = params) do
    query = Map.get(params, "query", "")
    status = Map.get(params, "status", "")
    sort_by = Map.get(params, "sort_by", "")
    sort_order = Map.get(params, "sort_order", "asc")
    page = params |> Map.get("page", "1") |> String.to_integer()
    per_page = params |> Map.get("per_page", "#{@default_per_page}") |> String.to_integer()

    current_directory = CmsDirectories.get_cms_directory!(id)

    items =
      CmsListing.fetch_items(
        {:directory, id},
        query,
        status,
        page: page,
        per_page: per_page,
        sort_by: sort_by,
        sort_order: sort_order
      )

    total_count = CmsListing.count_items({:directory, id}, query, status)
    max_page = ceil(total_count / per_page)

    socket
    |> assign(:items, items)
    |> assign(:cms_directories, extract_directories(items))
    |> assign(:cms_pages, extract_pages(items))
    |> assign(:current_directory, current_directory)
    |> assign(:page_title, gettext("Directories"))
    |> assign(:query, query)
    |> assign(:status, status)
    |> assign(:sort_by, sort_by)
    |> assign(:sort_order, sort_order)
    |> assign(:page, page)
    |> assign(:per_page, per_page)
    |> assign(:total_count, total_count)
    |> assign(:max_page, max_page)
  end

  defp apply_action(socket, :index, params) do
    query = Map.get(params, "query", "")
    status = Map.get(params, "status", "")
    sort_by = Map.get(params, "sort_by", "")
    sort_order = Map.get(params, "sort_order", "asc")
    page = params |> Map.get("page", "1") |> String.to_integer()
    per_page = params |> Map.get("per_page", "#{@default_per_page}") |> String.to_integer()

    items =
      CmsListing.fetch_items(
        :root,
        query,
        status,
        page: page,
        per_page: per_page,
        sort_by: sort_by,
        sort_order: sort_order
      )

    total_count = CmsListing.count_items(:root, query, status)
    max_page = ceil(total_count / per_page)

    socket
    |> assign(:items, items)
    |> assign(:cms_directories, extract_directories(items))
    |> assign(:cms_pages, extract_pages(items))
    |> assign(:current_directory, nil)
    |> assign(:page_title, gettext("Directories"))
    |> assign(:query, query)
    |> assign(:status, status)
    |> assign(:sort_by, sort_by)
    |> assign(:sort_order, sort_order)
    |> assign(:page, page)
    |> assign(:per_page, per_page)
    |> assign(:total_count, total_count)
    |> assign(:max_page, max_page)
  end

  @impl Phoenix.LiveView
  def handle_info({ScalesCmsWeb.CmsDirectoryLive.FormComponent, {:saved, _cms_directory}}, socket) do
    socket
    |> assign(:edit_directory, nil)
    |> assign(:new_directory, nil)
    |> close_modal("cms_directory-modal")
    |> close_modal("cms_directory-edit-modal")
    |> reload_listing()
    |> then(&{:noreply, &1})
  end

  def handle_info({ScalesCmsWeb.CmsPageLive.FormComponent, {:saved, _cms_page}}, socket) do
    socket
    |> close_modal("cms_page-modal")
    |> reload_listing()
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

    socket
    |> reload_listing()
    |> then(&{:noreply, &1})
  rescue
    Ecto.ConstraintError ->
      {:noreply,
       socket
       |> put_flash(:error, "Directory not empty")}
  end

  def handle_event("delete-page", %{"id" => id}, socket) do
    ScalesCms.Cms.Flows.Pages.DeletePage.perform(id)

    socket
    |> reload_listing()
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

  def handle_event("edit-directory", %{"id" => id}, socket) do
    cms_directory = CmsDirectories.get_cms_directory!(id)

    socket
    |> assign(:edit_directory, cms_directory)
    |> open_modal("cms_directory-edit-modal")
    |> then(&{:noreply, &1})
  end

  def handle_event("new-directory", _params, socket) do
    current_directory = socket.assigns.current_directory

    new_directory = %ScalesCms.Cms.CmsDirectory{
      cms_directory_id: current_directory && current_directory.id
    }

    socket
    |> assign(:new_directory, new_directory)
    |> open_modal("cms_directory-modal")
    |> then(&{:noreply, &1})
  end

  def handle_event("search", %{"query" => query}, socket) do
    status = socket.assigns.status
    sort_by = socket.assigns.sort_by
    sort_order = socket.assigns.sort_order
    cms_directory = socket.assigns.current_directory
    per_page = socket.assigns.per_page

    socket
    |> push_patch(
      to:
        CmsDirectoryHelper.build_filter_path(
          cms_directory,
          query,
          status,
          sort_by,
          sort_order,
          1,
          per_page
        )
    )
    |> then(&{:noreply, &1})
  end

  def handle_event("filter_status", %{"status" => status}, socket) do
    query = socket.assigns.query
    sort_by = socket.assigns.sort_by
    sort_order = socket.assigns.sort_order
    per_page = socket.assigns.per_page

    socket
    |> push_patch(
      to:
        CmsDirectoryHelper.build_filter_path(
          socket.assigns.current_directory,
          query,
          status,
          sort_by,
          sort_order,
          1,
          per_page
        )
    )
    |> then(&{:noreply, &1})
  end

  def handle_event("sort", %{"column" => column}, socket) do
    query = socket.assigns.query
    status = socket.assigns.status
    current_sort_by = socket.assigns.sort_by
    current_sort_order = socket.assigns.sort_order
    per_page = socket.assigns.per_page

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
          new_sort_order,
          1,
          per_page
        )
    )
    |> then(&{:noreply, &1})
  end

  def handle_event("paginate", %{"page" => page, "per-page" => per_page}, socket) do
    query = socket.assigns.query
    status = socket.assigns.status
    sort_by = socket.assigns.sort_by
    sort_order = socket.assigns.sort_order

    page = String.to_integer(page)
    per_page = String.to_integer(per_page)

    socket
    |> push_patch(
      to:
        CmsDirectoryHelper.build_filter_path(
          socket.assigns.current_directory,
          query,
          status,
          sort_by,
          sort_order,
          page,
          per_page
        )
    )
    |> then(&{:noreply, &1})
  end

  defp reload_listing(socket) do
    query = socket.assigns.query
    status = socket.assigns.status
    sort_by = socket.assigns.sort_by
    sort_order = socket.assigns.sort_order
    page = socket.assigns.page
    per_page = socket.assigns.per_page

    {scope, current_directory} =
      case socket.assigns.current_directory do
        nil -> {:root, nil}
        directory -> {{:directory, directory.id}, directory}
      end

    items =
      CmsListing.fetch_items(
        scope,
        query,
        status,
        page: page,
        per_page: per_page,
        sort_by: sort_by,
        sort_order: sort_order
      )

    total_count = CmsListing.count_items(scope, query, status)
    max_page = ceil(total_count / per_page)

    socket
    |> assign(:items, items)
    |> assign(:cms_directories, extract_directories(items))
    |> assign(:cms_pages, extract_pages(items))
    |> assign(:current_directory, current_directory)
    |> assign(:total_count, total_count)
    |> assign(:max_page, max_page)
  end

  defp extract_directories(items) do
    items
    |> Enum.filter(&(&1.type == :directory))
    |> Enum.map(& &1.data)
  end

  defp extract_pages(items) do
    items
    |> Enum.filter(&(&1.type == :page))
    |> Enum.map(& &1.data)
  end
end
