defmodule GlorioCmsWeb.CmsPageLiveTest do
  use GlorioCmsWeb.ConnCase

  import Phoenix.LiveViewTest
  import GlorioCms.CmsFixtures

  @create_attrs %{title: "some title", slug: "some slug", deleted_at: "2024-11-24T12:34:00"}
  @update_attrs %{
    title: "some updated title",
    slug: "some updated slug",
    deleted_at: "2024-11-25T12:34:00"
  }
  @invalid_attrs %{title: nil, slug: nil, deleted_at: nil}

  defp create_cms_page(_) do
    cms_page = cms_page_fixture()
    %{cms_page: cms_page}
  end

  describe "Index" do
    setup [:create_cms_page]

    test "lists all cms_pages", %{conn: conn, cms_page: cms_page} do
      {:ok, _index_live, html} = live(conn, ~p"/cms/cms_pages")

      assert html =~ "Listing Cms pages"
      assert html =~ cms_page.title
    end

    test "saves new cms_page", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cms/cms_pages")

      assert index_live |> element("a", "New Cms page") |> render_click() =~
               "New Cms page"

      assert_patch(index_live, ~p"/cms/cms_pages/new")

      assert index_live
             |> form("#cms_page-form", cms_page: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#cms_page-form", cms_page: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cms/cms_pages")

      html = render(index_live)
      assert html =~ "Cms page created successfully"
      assert html =~ "some title"
    end

    test "updates cms_page in listing", %{conn: conn, cms_page: cms_page} do
      {:ok, index_live, _html} = live(conn, ~p"/cms/cms_pages")

      assert index_live |> element("#cms_pages-#{cms_page.id} a", "Edit") |> render_click() =~
               "Edit Cms page"

      assert_patch(index_live, ~p"/cms/cms_pages/#{cms_page}/edit")

      assert index_live
             |> form("#cms_page-form", cms_page: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#cms_page-form", cms_page: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cms/cms_pages")

      html = render(index_live)
      assert html =~ "Cms page updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes cms_page in listing", %{conn: conn, cms_page: cms_page} do
      {:ok, index_live, _html} = live(conn, ~p"/cms/cms_pages")

      assert index_live |> element("#cms_pages-#{cms_page.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#cms_pages-#{cms_page.id}")
    end
  end

  describe "Show" do
    setup [:create_cms_page]

    test "displays cms_page", %{conn: conn, cms_page: cms_page} do
      {:ok, _show_live, html} = live(conn, ~p"/cms/cms_pages/#{cms_page}")

      assert html =~ "Show Cms page"
      assert html =~ cms_page.title
    end

    test "updates cms_page within modal", %{conn: conn, cms_page: cms_page} do
      {:ok, show_live, _html} = live(conn, ~p"/cms/cms_pages/#{cms_page}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Cms page"

      assert_patch(show_live, ~p"/cms/cms_pages/#{cms_page}/show/edit")

      assert show_live
             |> form("#cms_page-form", cms_page: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#cms_page-form", cms_page: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/cms/cms_pages/#{cms_page}")

      html = render(show_live)
      assert html =~ "Cms page updated successfully"
      assert html =~ "some updated title"
    end
  end
end
