defmodule ScalesCmsWeb.Components.HelperComponents.PageSearch do
  @moduledoc """
  The wrapper that goes around a block that is rendered in the WYSIWYG editor
  """
  use ScalesCmsWeb, :live_component

  @impl true
  def mount(socket) do
    socket
    |> assign_new(:pages, fn ->
      ScalesCms.Cms.CmsPages.list_paginated_cms_pages(0, 25)
    end)
    |> assign(value: nil)
    |> assign(search_value: nil)
    |> assign(display: nil)
    |> assign(:closed, true)
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveComponent
  def update(%{field: %{value: nil}} = params, socket), do: handle_empty_page(params, socket)
  def update(%{field: %{value: ""}} = params, socket), do: handle_empty_page(params, socket)
  def update(%{field: %{value: 0}} = params, socket), do: handle_empty_page(params, socket)

  def update(%{field: %{value: value}} = params, socket) do
    page = ScalesCms.Cms.CmsPages.get_cms_page!(value)

    socket
    |> assign(pages: ScalesCms.Cms.CmsPages.list_paginated_cms_pages(0, 25))
    |> assign(value: value)
    |> assign(field: params.field)
    |> assign(search_value: nil)
    |> assign(display: page.title)
    |> assign(closed: true)
    |> then(&{:ok, &1})
  end

  defp handle_empty_page(params, socket) do
    socket
    |> assign(pages: ScalesCms.Cms.CmsPages.list_paginated_cms_pages(0, 25))
    |> assign(value: nil)
    |> assign(field: params.field)
    |> assign(search_value: nil)
    |> assign(display: nil)
    |> assign(closed: true)
    |> then(&{:ok, &1})
  end

  @impl Phoenix.LiveComponent
  def handle_event("toggle-open", _, socket) do
    {:noreply, assign(socket, :closed, !socket.assigns.closed)}
  end

  def handle_event("search", %{"search" => search}, socket) do
    pages = ScalesCms.Cms.CmsPages.search_pages(search)
    {:noreply, assign(socket, pages: pages)}
  end

  def handle_event("set-value", %{"value" => nil}, socket) do
    {:noreply, assign(socket, value: nil, display: nil, closed: true)}
  end

  def handle_event("set-value", %{"value" => ""}, socket) do
    {:noreply, assign(socket, value: nil, display: nil, closed: true)}
  end

  def handle_event("set-value", %{"value" => 0}, socket) do
    {:noreply, assign(socket, value: nil, display: nil, closed: true)}
  end

  def handle_event("set-value", %{"value" => value}, socket) do
    IO.inspect(value)

    page = ScalesCms.Cms.CmsPages.get_cms_page!(value)

    {:noreply, assign(socket, value: value, display: page.title, closed: true)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="">
      <.input type="hidden" field={@field} value={@value} />
      <.label>{gettext("Page")}</.label>

      <div
        class="flex mt-2 p-2 border justify-between block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 border-zinc-300 focus:border-zinc-400"
        phx-click="toggle-open"
        phx-target={@myself}
        class=" cursor-pointer"
      >
        <div>
          {@display} {if @display == nil, do: gettext("Select page")}
        </div>

        <div class="w-[24px] h-[24px]">
          <.svg
            type="toggle_up"
            class={"w-[16px] h-[16px] mt-[6px] transition-all ease-in-out delay-150 duration-300 #{if @closed, do: "rotate-180", else: ""}"}
          />
        </div>
      </div>

      <div class={"absolute shadow-md	 w-[400px] grid #{if @closed, do: "grid-rows-[0fr]", else: "grid-rows-[1fr] bg-white border"} transition-all ease-in-out delay-150 duration-300"}>
        <ul class="grid gap-2 overflow-hidden">
          <li class="">
            <div class="p-[12px] flex border-b ">
              <.icon name="hero-magnifying-glass" class="mr-[12px]" />

              <input
                name="search"
                type="text"
                phx-debounce="300"
                phx-value={@search_value}
                phx-target={@myself}
                phx-change="search"
                class="w-full p-0 m-0 border-none focus:ring-0 focus:border-none focus:outline-none text-sm"
                placeholder={gettext("Search for a page")}
              />
            </div>
            <ul class="max-h-[300px] overflow-auto">
              <li
                phx-click="set-value"
                phx-target={@myself}
                phx-value={nil}
                class="border-b cursor-pointer p-[12px] hover:bg-zinc-100 text-sm"
              >
                {gettext("None")}
              </li>
              <li
                :for={page <- @pages}
                value={page.id}
                phx-click="set-value"
                phx-target={@myself}
                phx-value={page.id}
                class="border-b cursor-pointer p-[12px]  hover:bg-zinc-100 text-sm"
              >
                {page.title}
              </li>
            </ul>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
