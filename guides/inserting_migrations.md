## Inserting migrations
To insert the migrations in your host application run the following mix task:

```bash
mix scales_cms.generate_migrations
```

et voila, the migrations are inserted in your host application. Now run the ecto migration;

```bash
mix ecto.migrate
```
