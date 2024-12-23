defmodule ScalesCms.CmsTest do
  use ScalesCms.DataCase

  describe "cms_directories" do
    alias ScalesCms.Cms.CmsDirectory
    alias ScalesCms.Cms.CmsDirectories

    import ScalesCms.CmsFixtures

    @invalid_attrs %{title: nil, slug: nil, deleted_at: nil}

    test "list_cms_directories/0 returns all cms_directories" do
      cms_directory = cms_directory_fixture()
      assert CmsDirectories.list_cms_directories() == [cms_directory]
    end

    test "get_cms_directory!/1 returns the cms_directory with given id" do
      cms_directory = cms_directory_fixture()
      assert CmsDirectories.get_cms_directory!(cms_directory.id) == cms_directory
    end

    test "create_cms_directory/1 with valid data creates a cms_directory" do
      valid_attrs = %{title: "some title", slug: "some slug", deleted_at: ~N[2024-11-24 12:16:00]}

      assert {:ok, %CmsDirectory{} = cms_directory} =
               CmsDirectories.create_cms_directory(valid_attrs)

      assert cms_directory.title == "some title"
      assert cms_directory.slug == "some slug"
      assert cms_directory.deleted_at == ~N[2024-11-24 12:16:00]
    end

    test "create_cms_directory/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CmsDirectories.create_cms_directory(@invalid_attrs)
    end

    test "update_cms_directory/2 with valid data updates the cms_directory" do
      cms_directory = cms_directory_fixture()

      update_attrs = %{
        title: "some updated title",
        slug: "some updated slug",
        deleted_at: ~N[2024-11-25 12:16:00]
      }

      assert {:ok, %CmsDirectory{} = cms_directory} =
               CmsDirectories.update_cms_directory(cms_directory, update_attrs)

      assert cms_directory.title == "some updated title"
      assert cms_directory.slug == "some updated slug"
      assert cms_directory.deleted_at == ~N[2024-11-25 12:16:00]
    end

    test "update_cms_directory/2 with invalid data returns error changeset" do
      cms_directory = cms_directory_fixture()

      assert {:error, %Ecto.Changeset{}} =
               CmsDirectories.update_cms_directory(cms_directory, @invalid_attrs)

      assert cms_directory == CmsDirectories.get_cms_directory!(cms_directory.id)
    end

    test "delete_cms_directory/1 deletes the cms_directory" do
      cms_directory = cms_directory_fixture()
      assert {:ok, %CmsDirectory{}} = CmsDirectories.delete_cms_directory(cms_directory)

      assert_raise Ecto.NoResultsError, fn ->
        CmsDirectories.get_cms_directory!(cms_directory.id)
      end
    end

    test "change_cms_directory/1 returns a cms_directory changeset" do
      cms_directory = cms_directory_fixture()
      assert %Ecto.Changeset{} = CmsDirectories.change_cms_directory(cms_directory)
    end
  end

  describe "cms_pages" do
    alias ScalesCms.Cms.CmsPage
    alias ScalesCms.Cms.CmsPages

    import ScalesCms.CmsFixtures

    @invalid_attrs %{title: nil, slug: nil, deleted_at: nil}

    test "list_cms_pages/0 returns all cms_pages" do
      cms_page = cms_page_fixture()
      assert CmsPages.list_cms_pages() == [cms_page]
    end

    test "get_cms_page!/1 returns the cms_page with given id" do
      cms_page = cms_page_fixture()
      assert CmsPages.get_cms_page!(cms_page.id) == cms_page
    end

    test "create_cms_page/1 with valid data creates a cms_page" do
      valid_attrs = %{title: "some title", slug: "some slug", deleted_at: ~N[2024-11-24 12:34:00]}

      assert {:ok, %CmsPage{} = cms_page} = CmsPages.create_cms_page(valid_attrs)
      assert cms_page.title == "some title"
      assert cms_page.slug == "some slug"
      assert cms_page.deleted_at == ~N[2024-11-24 12:34:00]
    end

    test "create_cms_page/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CmsPages.create_cms_page(@invalid_attrs)
    end

    test "update_cms_page/2 with valid data updates the cms_page" do
      cms_page = cms_page_fixture()

      update_attrs = %{
        title: "some updated title",
        slug: "some updated slug",
        deleted_at: ~N[2024-11-25 12:34:00]
      }

      assert {:ok, %CmsPage{} = cms_page} = CmsPages.update_cms_page(cms_page, update_attrs)
      assert cms_page.title == "some updated title"
      assert cms_page.slug == "some updated slug"
      assert cms_page.deleted_at == ~N[2024-11-25 12:34:00]
    end

    test "update_cms_page/2 with invalid data returns error changeset" do
      cms_page = cms_page_fixture()
      assert {:error, %Ecto.Changeset{}} = CmsPages.update_cms_page(cms_page, @invalid_attrs)
      assert cms_page == CmsPages.get_cms_page!(cms_page.id)
    end

    test "delete_cms_page/1 deletes the cms_page" do
      cms_page = cms_page_fixture()
      assert {:ok, %CmsPage{}} = CmsPages.delete_cms_page(cms_page)
      assert_raise Ecto.NoResultsError, fn -> CmsPages.get_cms_page!(cms_page.id) end
    end

    test "change_cms_page/1 returns a cms_page changeset" do
      cms_page = cms_page_fixture()
      assert %Ecto.Changeset{} = CmsPages.change_cms_page(cms_page)
    end
  end

  describe "cms_page_variants" do
    alias ScalesCms.Cms.CmsPageVariant
    alias ScalesCms.Cms.CmsPageVariants

    import ScalesCms.CmsFixtures

    @invalid_attrs %{version: nil, title: nil, published_at: nil, locale: nil}

    test "list_cms_page_variants/0 returns all cms_page_variants" do
      cms_page_variant = cms_page_variant_fixture()
      assert CmsPageVariants.list_cms_page_variants() == [cms_page_variant]
    end

    test "get_cms_page_variant!/1 returns the cms_page_variant with given id" do
      cms_page_variant = cms_page_variant_fixture()
      assert CmsPageVariants.get_cms_page_variant!(cms_page_variant.id) == cms_page_variant
    end

    test "create_cms_page_variant/1 with valid data creates a cms_page_variant" do
      valid_attrs = %{
        version: 42,
        title: "some title",
        published_at: ~N[2024-11-24 12:50:00],
        locale: "some locale"
      }

      assert {:ok, %CmsPageVariant{} = cms_page_variant} =
               CmsPageVariants.create_cms_page_variant(valid_attrs)

      assert cms_page_variant.version == 42
      assert cms_page_variant.title == "some title"
      assert cms_page_variant.published_at == ~N[2024-11-24 12:50:00]
      assert cms_page_variant.locale == "some locale"
    end

    test "create_cms_page_variant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CmsPageVariants.create_cms_page_variant(@invalid_attrs)
    end

    test "update_cms_page_variant/2 with valid data updates the cms_page_variant" do
      cms_page_variant = cms_page_variant_fixture()

      update_attrs = %{
        version: 43,
        title: "some updated title",
        published_at: ~N[2024-11-25 12:50:00],
        locale: "some updated locale"
      }

      assert {:ok, %CmsPageVariant{} = cms_page_variant} =
               CmsPageVariants.update_cms_page_variant(cms_page_variant, update_attrs)

      assert cms_page_variant.version == 43
      assert cms_page_variant.title == "some updated title"
      assert cms_page_variant.published_at == ~N[2024-11-25 12:50:00]
      assert cms_page_variant.locale == "some updated locale"
    end

    test "update_cms_page_variant/2 with invalid data returns error changeset" do
      cms_page_variant = cms_page_variant_fixture()

      assert {:error, %Ecto.Changeset{}} =
               CmsPageVariants.update_cms_page_variant(cms_page_variant, @invalid_attrs)

      assert cms_page_variant == CmsPageVariants.get_cms_page_variant!(cms_page_variant.id)
    end

    test "delete_cms_page_variant/1 deletes the cms_page_variant" do
      cms_page_variant = cms_page_variant_fixture()
      assert {:ok, %CmsPageVariant{}} = CmsPageVariants.delete_cms_page_variant(cms_page_variant)

      assert_raise Ecto.NoResultsError, fn ->
        CmsPageVariants.get_cms_page_variant!(cms_page_variant.id)
      end
    end

    test "change_cms_page_variant/1 returns a cms_page_variant changeset" do
      cms_page_variant = cms_page_variant_fixture()
      assert %Ecto.Changeset{} = CmsPageVariants.change_cms_page_variant(cms_page_variant)
    end
  end

  describe "cms_page_variant_blocks" do
    alias ScalesCms.Cms.CmsPageVariantBlock
    alias ScalesCms.Cms.CmsPageVariantBlocks

    import ScalesCms.CmsFixtures

    @invalid_attrs %{sort_order: nil, component_type: nil, properties: nil}

    test "list_cms_page_variant_blocks/0 returns all cms_page_variant_blocks" do
      cms_page_variant_block = cms_page_variant_block_fixture()
      assert CmsPageVariantBlocks.list_cms_page_variant_blocks() == [cms_page_variant_block]
    end

    test "get_cms_page_variant_block!/1 returns the cms_page_variant_block with given id" do
      cms_page_variant_block = cms_page_variant_block_fixture()

      assert CmsPageVariantBlocks.get_cms_page_variant_block!(cms_page_variant_block.id) ==
               cms_page_variant_block
    end

    test "create_cms_page_variant_block/1 with valid data creates a cms_page_variant_block" do
      valid_attrs = %{sort_order: 42, component_type: "some component_type", properties: %{}}

      assert {:ok, %CmsPageVariantBlock{} = cms_page_variant_block} =
               CmsPageVariantBlocks.create_cms_page_variant_block(valid_attrs)

      assert cms_page_variant_block.sort_order == 42
      assert cms_page_variant_block.component_type == "some component_type"
      assert cms_page_variant_block.properties == %{}
    end

    test "create_cms_page_variant_block/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               CmsPageVariantBlocks.create_cms_page_variant_block(@invalid_attrs)
    end

    test "update_cms_page_variant_block/2 with valid data updates the cms_page_variant_block" do
      cms_page_variant_block = cms_page_variant_block_fixture()

      update_attrs = %{
        sort_order: 43,
        component_type: "some updated component_type",
        properties: %{}
      }

      assert {:ok, %CmsPageVariantBlock{} = cms_page_variant_block} =
               CmsPageVariantBlocks.update_cms_page_variant_block(
                 cms_page_variant_block,
                 update_attrs
               )

      assert cms_page_variant_block.sort_order == 43
      assert cms_page_variant_block.component_type == "some updated component_type"
      assert cms_page_variant_block.properties == %{}
    end

    test "update_cms_page_variant_block/2 with invalid data returns error changeset" do
      cms_page_variant_block = cms_page_variant_block_fixture()

      assert {:error, %Ecto.Changeset{}} =
               CmsPageVariantBlocks.update_cms_page_variant_block(
                 cms_page_variant_block,
                 @invalid_attrs
               )

      assert cms_page_variant_block ==
               CmsPageVariantBlocks.get_cms_page_variant_block!(cms_page_variant_block.id)
    end

    test "delete_cms_page_variant_block/1 deletes the cms_page_variant_block" do
      cms_page_variant_block = cms_page_variant_block_fixture()

      assert {:ok, %CmsPageVariantBlock{}} =
               CmsPageVariantBlocks.delete_cms_page_variant_block(cms_page_variant_block)

      assert_raise Ecto.NoResultsError, fn ->
        CmsPageVariantBlocks.get_cms_page_variant_block!(cms_page_variant_block.id)
      end
    end

    test "change_cms_page_variant_block/1 returns a cms_page_variant_block changeset" do
      cms_page_variant_block = cms_page_variant_block_fixture()

      assert %Ecto.Changeset{} =
               CmsPageVariantBlocks.change_cms_page_variant_block(cms_page_variant_block)
    end
  end
end
