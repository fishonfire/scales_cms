defmodule ScalesCmsWeb.CmsPageLiveTest do
  use ScalesCmsWeb.ConnCase

  import Phoenix.LiveViewTest
  import ScalesCms.CmsFixtures

  @create_attrs %{title: "some title"}
  # @update_attrs %{
  #   title: "some updated title"
  # }
  @invalid_attrs %{title: nil}

  defp create_cms_page(_) do
    cms_page = cms_page_fixture()
    %{cms_page: cms_page}
  end

  describe "Index" do
    setup [:create_cms_page]

    test "clicks new page", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cms/directories")

      assert index_live
             |> element(".new-cms-page")
             |> render_click()

      assert_patch(index_live, ~p"/cms/pages/new")
    end

    test "saves new cms_page", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cms/pages/new")

      assert index_live
             |> form("#cms_page-form", cms_page: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#cms_page-form", cms_page: @create_attrs)
             |> render_submit()
             |> follow_redirect(conn)

      assert_redirect(index_live, ~p"/cms/directories")
    end

    test "deletes cms_page in listing", %{conn: conn, cms_page: cms_page} do
      {:ok, index_live, _html} = live(conn, ~p"/cms/directories")

      assert index_live |> element("#delete-page-#{cms_page.id}") |> render_click()
      refute has_element?(index_live, "#cms_pages-#{cms_page.id}")
    end
  end
end
