defmodule GlorioCmsWeb.CmsDirectoryLiveTest do
  use GlorioCmsWeb.ConnCase

  import Phoenix.LiveViewTest
  import GlorioCms.CmsFixtures

  @create_attrs %{title: "some title", slug: "some slug", deleted_at: "2024-11-24T12:16:00"}
  @update_attrs %{
    title: "some updated title",
    slug: "some updated slug",
    deleted_at: "2024-11-25T12:16:00"
  }
  @invalid_attrs %{title: nil, slug: nil, deleted_at: nil}

  defp create_cms_directory(_) do
    cms_directory = cms_directory_fixture()
    %{cms_directory: cms_directory}
  end

  describe "Index" do
    setup [:create_cms_directory]

    test "lists all cms_directories", %{conn: conn, cms_directory: cms_directory} do
      {:ok, _index_live, html} = live(conn, ~p"/cms_directories")

      assert html =~ "Listing Cms directories"
      assert html =~ cms_directory.title
    end

    test "saves new cms_directory", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cms_directories")

      assert index_live |> element("a", "New Cms directory") |> render_click() =~
               "New Cms directory"

      assert_patch(index_live, ~p"/cms_directories/new")

      assert index_live
             |> form("#cms_directory-form", cms_directory: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#cms_directory-form", cms_directory: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cms_directories")

      html = render(index_live)
      assert html =~ "Cms directory created successfully"
      assert html =~ "some title"
    end

    test "updates cms_directory in listing", %{conn: conn, cms_directory: cms_directory} do
      {:ok, index_live, _html} = live(conn, ~p"/cms_directories")

      assert index_live
             |> element("#cms_directories-#{cms_directory.id} a", "Edit")
             |> render_click() =~
               "Edit Cms directory"

      assert_patch(index_live, ~p"/cms/cms_directories/#{cms_directory}/edit")

      assert index_live
             |> form("#cms_directory-form", cms_directory: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#cms_directory-form", cms_directory: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cms_directories")

      html = render(index_live)
      assert html =~ "Cms directory updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes cms_directory in listing", %{conn: conn, cms_directory: cms_directory} do
      {:ok, index_live, _html} = live(conn, ~p"/cms_directories")

      assert index_live
             |> element("#cms_directories-#{cms_directory.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#cms_directories-#{cms_directory.id}")
    end
  end

  describe "Show" do
    setup [:create_cms_directory]

    test "displays cms_directory", %{conn: conn, cms_directory: cms_directory} do
      {:ok, _show_live, html} = live(conn, ~p"/cms/cms_directories/#{cms_directory}")

      assert html =~ "Show Cms directory"
      assert html =~ cms_directory.title
    end

    test "updates cms_directory within modal", %{conn: conn, cms_directory: cms_directory} do
      {:ok, show_live, _html} = live(conn, ~p"/cms/cms_directories/#{cms_directory}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Cms directory"

      assert_patch(show_live, ~p"/cms/cms_directories/#{cms_directory}/show/edit")

      assert show_live
             |> form("#cms_directory-form", cms_directory: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#cms_directory-form", cms_directory: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/cms/cms_directories/#{cms_directory}")

      html = render(show_live)
      assert html =~ "Cms directory updated successfully"
      assert html =~ "some updated title"
    end
  end
end
