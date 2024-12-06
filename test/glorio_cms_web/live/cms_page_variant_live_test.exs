defmodule GlorioCmsWeb.CmsPageVariantLiveTest do
  use GlorioCmsWeb.ConnCase

  import Phoenix.LiveViewTest
  import GlorioCms.CmsFixtures

  @create_attrs %{
    version: 42,
    title: "some title",
    published_at: "2024-11-24T12:50:00",
    locale: "some locale"
  }
  @update_attrs %{
    version: 43,
    title: "some updated title",
    published_at: "2024-11-25T12:50:00",
    locale: "some updated locale"
  }
  @invalid_attrs %{version: nil, title: nil, published_at: nil, locale: nil}

  defp create_cms_page_variant(_) do
    cms_page_variant = cms_page_variant_fixture()
    %{cms_page_variant: cms_page_variant}
  end

  describe "Index" do
    setup [:create_cms_page_variant]

    test "lists all cms_page_variants", %{conn: conn, cms_page_variant: cms_page_variant} do
      {:ok, _index_live, html} = live(conn, ~p"/cms/cms_page_variants")

      assert html =~ "Listing Cms page variants"
      assert html =~ cms_page_variant.title
    end

    test "saves new cms_page_variant", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cms/cms_page_variants")

      assert index_live |> element("a", "New Cms page variant") |> render_click() =~
               "New Cms page variant"

      assert_patch(index_live, ~p"/cms/cms_page_variants/new")

      assert index_live
             |> form("#cms_page_variant-form", cms_page_variant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#cms_page_variant-form", cms_page_variant: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cms/cms_page_variants")

      html = render(index_live)
      assert html =~ "Cms page variant created successfully"
      assert html =~ "some title"
    end

    test "updates cms_page_variant in listing", %{conn: conn, cms_page_variant: cms_page_variant} do
      {:ok, index_live, _html} = live(conn, ~p"/cms/cms_page_variants")

      assert index_live
             |> element("#cms_page_variants-#{cms_page_variant.id} a", "Edit")
             |> render_click() =~
               "Edit Cms page variant"

      assert_patch(index_live, ~p"/cms/cms_page_variants/#{cms_page_variant}/edit")

      assert index_live
             |> form("#cms_page_variant-form", cms_page_variant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#cms_page_variant-form", cms_page_variant: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cms/cms_page_variants")

      html = render(index_live)
      assert html =~ "Cms page variant updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes cms_page_variant in listing", %{conn: conn, cms_page_variant: cms_page_variant} do
      {:ok, index_live, _html} = live(conn, ~p"/cms/cms_page_variants")

      assert index_live
             |> element("#cms_page_variants-#{cms_page_variant.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#cms_page_variants-#{cms_page_variant.id}")
    end
  end

  describe "Show" do
    setup [:create_cms_page_variant]

    test "displays cms_page_variant", %{conn: conn, cms_page_variant: cms_page_variant} do
      {:ok, _show_live, html} = live(conn, ~p"/cms/cms_page_variants/#{cms_page_variant}")

      assert html =~ "Show Cms page variant"
      assert html =~ cms_page_variant.title
    end

    test "updates cms_page_variant within modal", %{
      conn: conn,
      cms_page_variant: cms_page_variant
    } do
      {:ok, show_live, _html} = live(conn, ~p"/cms/cms_page_variants/#{cms_page_variant}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Cms page variant"

      assert_patch(show_live, ~p"/cms/cms_page_variants/#{cms_page_variant}/show/edit")

      assert show_live
             |> form("#cms_page_variant-form", cms_page_variant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#cms_page_variant-form", cms_page_variant: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/cms/cms_page_variants/#{cms_page_variant}")

      html = render(show_live)
      assert html =~ "Cms page variant updated successfully"
      assert html =~ "some updated title"
    end
  end
end
