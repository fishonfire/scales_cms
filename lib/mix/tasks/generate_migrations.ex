if Code.ensure_loaded?(Ecto) do
  defmodule Mix.Tasks.ScalesCms.GenerateMigrations do
    @moduledoc """
    Copies pending ScalesCMS migrations into the host app.
    """
    use Mix.Task

    import Mix.Generator
    import Mix.Ecto, except: [migrations_path: 1]

    @shortdoc "Copies pending ScalesCMS migrations"

    @doc false
    @dialyzer {:no_return, run: 1}

    def run(args) do
      no_umbrella!("scales_cms.generate_migrations")
      repos = parse_repo(args)

      Enum.each(repos, fn repo ->
        ensure_repo(repo, args)

        target_path = migrations_path(repo)
        source_path = package_migrations_path()

        create_directory(target_path)

        source_migrations = migrations_in_dir(source_path)
        target_migrations = migrations_in_dir(target_path)
        migrated_versions = migrated_versions(repo)

        existing_versions =
          MapSet.union(
            MapSet.new(Map.keys(target_migrations)),
            MapSet.new(migrated_versions)
          )

        pending =
          source_migrations
          |> Enum.reject(fn {version, _file} -> MapSet.member?(existing_versions, version) end)

        if pending == [] do
          Mix.shell().info("No pending ScalesCMS migrations found for #{inspect(repo)}")
        else
          copy_pending_migrations(pending, target_path)
        end
      end)
    end

    defp copy_pending_migrations(pending, target_path) do
      Enum.each(pending, fn {_version, source_file} ->
        destination_file = Path.join(target_path, Path.basename(source_file))
        copy_file(source_file, destination_file)
        Mix.shell().info("Copied #{Path.basename(source_file)}")
      end)

      Mix.shell().info("""
      ScalesCMS migrations copied.

      Next step:
          mix ecto.migrate
      """)
    end

    defp package_migrations_path do
      :scales_cms
      |> :code.priv_dir()
      |> to_string()
      |> Path.join("repo/migrations")
    end

    defp migrations_in_dir(path) do
      path
      |> Path.join("*.exs")
      |> Path.wildcard()
      |> Enum.map(fn file ->
        {extract_version!(file), file}
      end)
      |> Map.new()
    end

    defp extract_version!(file) do
      file
      |> Path.basename()
      |> String.split("_", parts: 2)
      |> List.first()
    end

    defp migrated_versions(repo) do
      if Code.ensure_loaded?(Ecto.Migrator) &&
           function_exported?(Ecto.Migrator, :migrated_versions, 2) do
        Ecto.Migrator.migrated_versions(repo, migrations_path(repo))
        |> Enum.map(&to_string/1)
      else
        []
      end
    rescue
      _ -> []
    end

    if Code.ensure_loaded?(Ecto.Migrator) &&
         function_exported?(Ecto.Migrator, :migrations_path, 1) do
      def migrations_path(repo), do: Ecto.Migrator.migrations_path(repo)
    end

    if Code.ensure_loaded?(Mix.Ecto) && function_exported?(Mix.Ecto, :migrations_path, 1) do
      def migrations_path(repo), do: Mix.Ecto.migrations_path(repo)
    end
  end
end
