defmodule ScalesCmsWeb.CmsDirectoryLiveTest do
  use ScalesCmsWeb.ConnCase

  import Phoenix.LiveViewTest
  import ScalesCms.CmsFixtures

  use Gettext,
    backend: ScalesCmsWeb.Gettext

  @create_attrs %{title: "some new title"}
  @invalid_attrs %{title: nil}

  defp create_cms_directory(_) do
    cms_directory = cms_directory_fixture()
    %{cms_directory: cms_directory}
  end

  describe "Index" do
    setup [:create_cms_directory]

    test "lists all cms_directories", %{conn: conn, cms_directory: cms_directory} do
      conn = log_in_user(conn)
      {:ok, _index_live, html} = live(conn, ~p"/cms/directories")

      assert html =~ cms_directory.title
    end

    test "saves new cms_directory via modal", %{conn: conn} do
      conn = log_in_user(conn)

      {:ok, index_live, _html} = live(conn, ~p"/cms/directories")

      # Click the "New directory" button to open the modal
      index_live
      |> element("button[phx-click='new-directory']")
      |> render_click()

      assert index_live
             |> form("#cms_directory-form-new_directory", cms_directory: @invalid_attrs)
             |> render_change() =~ "mag niet leeg zijn"

      assert index_live
             |> form("#cms_directory-form-new_directory", cms_directory: @create_attrs)
             |> render_submit()

      html = render(index_live)
      assert html =~ gettext("Directory created successfully")
      assert html =~ "some new title"
    end

    test "deletes cms_directory in listing", %{conn: conn, cms_directory: cms_directory} do
      conn = log_in_user(conn)

      {:ok, index_live, _html} = live(conn, ~p"/cms/directories")

      assert index_live
             |> element("#cms_directories-#{cms_directory.id} .controls .delete")
             |> render_click()

      refute has_element?(index_live, "#cms_directories-#{cms_directory.id}")
    end
  end
end
