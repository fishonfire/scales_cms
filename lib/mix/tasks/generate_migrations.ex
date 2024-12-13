# Mix.Tasks.Ecto.Gen.Migration
if Code.ensure_loaded?(Ecto) do
  defmodule Mix.Tasks.ScalesCms.GenerateMigrations do
    @moduledoc """
    Provides the migrations for ScalesCMS
    """
    use Mix.Task

    import Macro, only: [camelize: 1, underscore: 1]
    import Mix.Generator
    import Mix.Ecto, except: [migrations_path: 1]

    @shortdoc "Generates the migrations for ScalesCMS"

    @doc false
    @dialyzer {:no_return, run: 1}

    def run(args) do
      no_umbrella!("scales_cms.generate_migrations")
      repos = parse_repo(args)
      name = "setup_cms_migrations"

      Enum.each(repos, fn repo ->
        ensure_repo(repo, args)
        path = Path.relative_to(migrations_path(repo), Mix.Project.app_path())
        file = Path.join(path, "#{timestamp()}_#{underscore(name)}.exs")
        create_directory(path)

        assigns = [mod: Module.concat([repo, Migrations, camelize(name)])]

        content =
          assigns
          |> migration_template
          |> format_string!

        create_file(file, content)

        if open?(file) and Mix.shell().yes?("Do you want to run this migration?") do
          Mix.Task.run("ecto.migrate", [repo])
        end
      end)
    end

    defp timestamp do
      {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
      "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
    end

    defp pad(i) when i < 10, do: <<?0, ?0 + i>>
    defp pad(i), do: to_string(i)

    if Code.ensure_loaded?(Code) && function_exported?(Code, :format_string!, 1) do
      @spec format_string!(String.t()) :: iodata()
      @dialyzer {:no_return, format_string!: 1}
      def format_string!(string), do: Code.format_string!(string)
    else
      @spec format_string!(String.t()) :: iodata()
      def format_string!(string), do: string
    end

    if Code.ensure_loaded?(Ecto.Migrator) &&
         function_exported?(Ecto.Migrator, :migrations_path, 1) do
      def migrations_path(repo), do: Ecto.Migrator.migrations_path(repo)
    end

    if Code.ensure_loaded?(Mix.Ecto) && function_exported?(Mix.Ecto, :migrations_path, 1) do
      def migrations_path(repo), do: Mix.Ecto.migrations_path(repo)
    end

    embed_template(:migration, """
    defmodule <%= inspect @mod %> do
      use Ecto.Migration

      def change do
        create table(:cms_directories) do
          add :title, :text
          add :slug, :string
          add :deleted_at, :naive_datetime
          add :cms_directory_id, references(:cms_directories, on_delete: :nothing)

          timestamps(type: :utc_datetime)
        end

        create index(:cms_directories, [:cms_directory_id])

        create table(:cms_pages) do
          add :title, :text
          add :slug, :string
          add :deleted_at, :naive_datetime
          add :cms_directory_id, references(:cms_directories, on_delete: :nothing)

          timestamps(type: :utc_datetime)
        end

        create index(:cms_pages, [:cms_directory_id])

        create table(:cms_page_variants) do
          add :title, :text
          add :published_at, :naive_datetime
          add :locale, :string
          add :version, :integer
          add :cms_page_id, references(:cms_pages, on_delete: :nothing)

          timestamps(type: :utc_datetime)
        end

        create index(:cms_page_variants, [:cms_page_id])
        create index(:cms_page_variants, [:cms_page_id, :locale, :published_at])

        create table(:cms_page_variant_blocks) do
          add :sort_order, :integer
          add :component_type, :string
          add :properties, :map, default: %{}
          add :cms_page_variant_id, references(:cms_page_variants, on_delete: :nothing)

          timestamps(type: :utc_datetime)
        end

        create index(:cms_page_variant_blocks, [:cms_page_variant_id])
        create index(:cms_page_variant_blocks, [:cms_page_variant_id, :sort_order])

        create table(:cms_page_locale_latest_variants) do
          add :cms_page_id, references(:cms_pages, on_delete: :nothing), null: false
          add :locale, :string, null: false
          add :cms_page_latest_variant_id, references(:cms_page_variants, on_delete: :nothing)

          add :cms_page_latest_published_variant_id,
              references(:cms_page_variants, on_delete: :nothing)

          timestamps(type: :utc_datetime)
        end
      end
    end
    """)
  end
end
