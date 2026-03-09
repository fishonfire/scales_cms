defmodule ScalesCmsWeb.Components.Live.HelperComponents.PaginationComponent do
  @moduledoc false
  use ScalesCmsWeb, :html

  @max_span 5

  attr :page, :integer, required: true
  attr :page_offset, :integer, required: false
  attr :per_page, :integer, required: true
  attr :max_page, :integer, required: true
  attr :id, :string, required: true
  attr :target, :any

  def render(%{max_page: 0} = assigns) do
    ~H"""
    <div></div>
    """
  end

  def render(assigns) do
    page_offset = assigns[:page_offset] || 0
    page = assigns[:page] + page_offset

    assigns =
      assigns
      |> assign(:page, page)
      |> assign(:max_span, @max_span)
      |> assign_new(:target, fn -> nil end)
      |> assign(:is_first_page, page == 1)
      |> assign(:is_last_page, page == assigns.max_page)

    ~H"""
    <div class="pagination-container">
      <!-- Previous Button -->
      <button
        class={"pagination-chevron #{if !@is_first_page, do: "active"}"}
        phx-click="paginate"
        phx-value-page={max(@page - 1, 1)}
        phx-value-per-page={@per_page}
        phx-target={@target}
        disabled={@is_first_page}
      >
        <.icon name="hero-chevron-left" />
      </button>
      
    <!-- Page Numbers -->
      <%= if @max_page > 2 * @max_span do %>
        <button
          :for={page_number <- page_start(@page, @max_page)..page_end(@page, @max_page)}
          class={"pagination-button #{if @page == page_number, do: "current"}"}
          phx-click="paginate"
          phx-value-page={page_number}
          phx-value-per-page={@per_page}
          phx-target={@target}
        >
          {page_number}
        </button>
      <% else %>
        <button
          :for={page_number <- 1..@max_page}
          class={"pagination-button #{if @page == page_number, do: "current"}"}
          phx-click="paginate"
          phx-value-page={page_number}
          phx-value-per-page={@per_page}
          phx-target={@target}
        >
          {page_number}
        </button>
      <% end %>
      
    <!-- Next Button -->
      <button
        class={"pagination-chevron #{if !@is_last_page, do: "active"}"}
        phx-click="paginate"
        phx-value-page={min(@page + 1, @max_page)}
        phx-value-per-page={@per_page}
        disabled={@is_last_page}
        phx-target={@target}
      >
        <.icon name="hero-chevron-right" />
      </button>
    </div>
    """
  end

  defp page_start(page, max_pages) do
    cond do
      max_pages <= 2 * @max_span -> 1
      page - @max_span > 1 -> page - @max_span
      true -> 1
    end
  end

  defp page_end(page, max_pages) do
    cond do
      max_pages <= 2 * @max_span -> max_pages
      page + @max_span < max_pages -> page + @max_span
      true -> max_pages
    end
  end
end
