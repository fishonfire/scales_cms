## Inserting migrations

- Create a migration to set up the ScalesCMS database tables:

```
mix ecto.gen.migration add_scales_cms
```
Then open the generated migration file and add:
```elixir
defmodule MyApp.Repo.Migrations.AddScalesCms do
  use Ecto.Migration

  def up, do: ScalesCms.Migration.up(version: 11)
  def down, do: ScalesCms.Migration.down(version: 1)
end
```
- Run `mix ecto.migrate` to run the migrations.

When a new version of ScalesCMS is released that includes schema changes, generate a new migration and call `up` with the new version number:
```elixir
defmodule MyApp.Repo.Migrations.UpgradeScalesCmsV12 do
  use Ecto.Migration

  def up, do: ScalesCms.Migration.up(version: 12)
  def down, do: ScalesCms.Migration.down(version: 12)
end
```
