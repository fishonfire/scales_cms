## Custom CSS and JS
To set up custom JS/CSS, enable the following in your config file:

```elixir
config :scales_cms, :custom_assets,
  enabled: true,
  css_file: "app.css",
  js_file: "app.js",
  prefix: "assets"

config :scales_cms,
  endpoint: CmsDemoWeb.Endpoint
```

The prefix is the directory, usually assets. The files, app.css and app.js, should be placed in the directory specified by the prefix. The files will be loaded in the head a of the HTML document.

The endpoint is configured to the endpoint of your application. This is necessary to ensure that the correct path is generated for the assets.
