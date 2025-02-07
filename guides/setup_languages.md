# Locales
## Default locale
Change the default locale by setting the following:
```elixir
config :scales_cms, :cms, default_locale: "nl-NL"
```

## Set the list of locales
To configure the list of the locales, set the following;

```elixir
config :scales_cms, :cms,
  available_locales: [
    %{code: "nl-NL", name: "Dutch"},
    %{code: "en-US", name: "English"},
    %{code: "fr-FR", name: "Français"}
  ]
```
