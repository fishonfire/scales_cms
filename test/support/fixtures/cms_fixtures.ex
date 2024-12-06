defmodule GlorioCms.CmsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GlorioCms.Cms` context.
  """

  @doc """
  Generate a cms_directory.
  """
  def cms_directory_fixture(attrs \\ %{}) do
    {:ok, cms_directory} =
      attrs
      |> Enum.into(%{
        deleted_at: ~N[2024-11-24 12:16:00],
        slug: "some slug",
        title: "some title"
      })
      |> GlorioCms.Cms.CmsDirectories.create_cms_directory()

    cms_directory
  end

  @doc """
  Generate a cms_page.
  """
  def cms_page_fixture(attrs \\ %{}) do
    {:ok, cms_page} =
      attrs
      |> Enum.into(%{
        deleted_at: ~N[2024-11-24 12:34:00],
        slug: "some slug",
        title: "some title"
      })
      |> GlorioCms.Cms.CmsPages.create_cms_page()

    cms_page
  end

  @doc """
  Generate a cms_page_variant.
  """
  def cms_page_variant_fixture(attrs \\ %{}) do
    {:ok, cms_page_variant} =
      attrs
      |> Enum.into(%{
        locale: "some locale",
        published_at: ~N[2024-11-24 12:50:00],
        title: "some title",
        version: 42
      })
      |> GlorioCms.Cms.CmsPageVariants.create_cms_page_variant()

    cms_page_variant
  end

  @doc """
  Generate a cms_page_variant_block.
  """
  def cms_page_variant_block_fixture(attrs \\ %{}) do
    {:ok, cms_page_variant_block} =
      attrs
      |> Enum.into(%{
        component_type: "some component_type",
        properties: %{},
        sort_order: 42
      })
      |> GlorioCms.Cms.CmsPageVariantBlocks.create_cms_page_variant_block()

    cms_page_variant_block
  end
end
