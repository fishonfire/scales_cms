defmodule ScalesCmsWeb.CmsBlockTemplatesLive.Index do
  alias ScalesCms.Cms.CmsBlockTemplate
  alias ScalesCms.Cms.CmsBlockTemplates
  use ScalesCmsWeb, :live_view

  alias ScalesCmsWeb.Components.LocaleSwitcher
  alias ScalesCmsWeb.Components.Live.HelperComponents.PaginationComponent

  alias ScalesCmsWeb.Helpers.CmsBlockTemplates, as: CmsBlockTemplatesHelper

  @default_per_page 20

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket
    |> assign(locale: ScalesCms.Cms.Helpers.Locales.default_locale())
    |> assign(:items, [])
    |> assign(:cms_block_templates, [])
    |> assign(:new_block_template, nil)
    |> assign(:page, 1)
    |> assign(:per_page, @default_per_page)
    |> assign(:total_count, 0)
    |> assign(:max_page, 0)
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    socket =
      socket
      |> assign(:params, params)
      |> fetch_list(params)

    {:noreply, socket}
  end

  defp fetch_list(socket, params) do
    locale = socket.assigns.locale
    query = Map.get(params, "query", "")
    template_mode = Map.get(params, "template_mode", "")
    sort_by = Map.get(params, "sort_by", "")
    sort_order = Map.get(params, "sort_order", "asc")
    page = params |> Map.get("page", "1") |> String.to_integer()
    per_page = params |> Map.get("per_page", "#{@default_per_page}") |> String.to_integer()

    block_templates =
      CmsBlockTemplates.fetch_cms_block_templates(
        query,
        (page - 1) * per_page,
        per_page,
        template_mode: template_mode,
        sort_by: sort_by,
        sort_order: sort_order,
        locale: locale
      )

    total_count =
      CmsBlockTemplates.count_block_templates(query, template_mode: template_mode, locale: locale)

    max_page = ceil(total_count / per_page)

    socket
    |> assign(:block_templates, block_templates)
    |> assign(:current_block_template, nil)
    |> assign(:query, query)
    |> assign(:template_mode, template_mode)
    |> assign(:sort_by, sort_by)
    |> assign(:sort_order, sort_order)
    |> assign(:page, page)
    |> assign(:per_page, per_page)
    |> assign(:total_count, total_count)
    |> assign(:max_page, max_page)
  end

  @impl Phoenix.LiveView
  def handle_info({ScalesCmsWeb.Components.LocaleSwitcher, {:locale_switched, locale}}, socket) do
    params = socket.assigns[:params] || %{}

    socket =
      socket
      |> assign(:locale, locale)
      |> fetch_list(params)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    cms_block_template = CmsBlockTemplates.get_cms_block_template!(id)

    {:ok, _} =
      CmsBlockTemplates.delete_cms_block_templates_by_template_family_id(
        cms_block_template.template_family_id
      )

    socket
    |> fetch_list(socket.assigns.params)
    |> then(&{:noreply, &1})
  rescue
    Ecto.ConstraintError ->
      {:noreply,
       socket
       |> put_flash(:error, "Template block not deleted")}
  end

  def handle_event("open", %{"id" => id}, socket) do
    socket
    |> push_navigate(to: ~p"/cms/block_templates/#{id}")
    |> then(&{:noreply, &1})
  end

  def handle_event("new", _params, socket) do
    socket
    |> assign(:new_block_template, %CmsBlockTemplate{})
    |> open_modal("cms-block-template-modal")
    |> then(&{:noreply, &1})
  end

  def handle_event("search", %{"query" => query}, socket) do
    template_mode = socket.assigns.template_mode
    sort_by = socket.assigns.sort_by
    sort_order = socket.assigns.sort_order
    per_page = socket.assigns.per_page

    socket
    |> push_patch(
      to:
        CmsBlockTemplatesHelper.build_filter_path(
          query,
          template_mode,
          sort_by,
          sort_order,
          1,
          per_page
        )
    )
    |> then(&{:noreply, &1})
  end

  def handle_event("filter-mode", %{"template_mode" => template_mode}, socket) do
    query = socket.assigns.query
    sort_by = socket.assigns.sort_by
    sort_order = socket.assigns.sort_order
    per_page = socket.assigns.per_page

    socket
    |> push_patch(
      to:
        CmsBlockTemplatesHelper.build_filter_path(
          query,
          template_mode,
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
    template_mode = socket.assigns.template_mode
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
        CmsBlockTemplatesHelper.build_filter_path(
          query,
          template_mode,
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
    template_mode = socket.assigns.template_mode
    sort_by = socket.assigns.sort_by
    sort_order = socket.assigns.sort_order

    page = String.to_integer(page)
    per_page = String.to_integer(per_page)

    socket
    |> push_patch(
      to:
        CmsBlockTemplatesHelper.build_filter_path(
          query,
          template_mode,
          sort_by,
          sort_order,
          page,
          per_page
        )
    )
    |> then(&{:noreply, &1})
  end
end
