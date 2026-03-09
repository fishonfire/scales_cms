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

    test "saves new cms_page via modal", %{conn: conn} do
      conn = log_in_user(conn)

      {:ok, index_live, _html} = live(conn, ~p"/cms/directories")

      # The modal form is always in the DOM, we can interact with it directly
      assert index_live
             |> form("#cms_page-form", cms_page: @invalid_attrs)
             |> render_change() =~ "mag niet leeg zijn"

      index_live
      |> form("#cms_page-form", cms_page: @create_attrs)
      |> render_submit()

      assert_redirect(index_live, ~p"/cms/directories")
    end

    @tag :skip
    test "deletes cms_page in listing", %{conn: conn, cms_page: cms_page} do
      conn = log_in_user(conn)

      {:ok, index_live, _html} = live(conn, ~p"/cms/directories")

      assert index_live
             |> element("#delete-page-#{cms_page.id}")
             |> render_click()

      refute has_element?(index_live, "#cms_pages-#{cms_page.id}")
    end
  end
end
