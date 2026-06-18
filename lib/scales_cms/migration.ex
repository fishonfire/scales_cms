defmodule ScalesCms.Migration do
  @moduledoc """
  Migrations for ScalesCMS.

  To use ScalesCMS migrations in your app, create a single Ecto migration and call
  `up/1` and `down/1` with the target version:

      defmodule MyApp.Repo.Migrations.AddScalesCms do
        use Ecto.Migration

        def up, do: ScalesCms.Migration.up(version: 11)
        def down, do: ScalesCms.Migration.down(version: 1)
      end

  You can also migrate incrementally when a new version of ScalesCMS is released by
  adding a new migration that calls `up` with the latest version number.

  ## Versions

  | Version | Description |
  |---------|-------------|
  | 1       | Create cms_directories |
  | 2       | Create cms_pages |
  | 3       | Create cms_page_variants |
  | 4       | Create cms_page_variant_blocks |
  | 5       | Create cms_page_locale_latest_variants |
  | 6       | Create cms_api_tokens |
  | 7       | Add stats (views, path) to cms_pages |
  | 8       | Create cms_media_library |
  | 9       | Enable pgcrypto extension |
  | 10      | Create cms_block_templates |
  | 11      | Add block template attributes to cms_page_variant_blocks |
  """

  use Ecto.Migration

  @current_version 11
  @initial_version 1

  @doc """
  Runs ScalesCMS migrations up to the given version.

  ## Options

    * `:version` - the target version to migrate to. Defaults to the current
      maximum version (11).

  ## Example

      ScalesCms.Migration.up(version: 11)
  """
  def up(opts \\ []) do
    version = Keyword.get(opts, :version, @current_version)
    Enum.each(@initial_version..version, &migrate(&1, :up))
  end

  @doc """
  Rolls back ScalesCMS migrations down to the given version (inclusive).

  ## Options

    * `:version` - the version to roll back to (inclusive). Defaults to the
      initial version (1).

  ## Example

      ScalesCms.Migration.down(version: 1)
  """
  def down(opts \\ []) do
    version = Keyword.get(opts, :version, @initial_version)
    Enum.each(@current_version..version//-1, &migrate(&1, :down))
  end

  defp migrate(version, direction) do
    module = Module.concat([ScalesCms, Migrations, "V#{version}"])
    apply(module, direction, [])
  end
end
