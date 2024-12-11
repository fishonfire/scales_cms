# ScalesCms

## How to set up in your project
- Add to the list of dependencies in `mix.exs`
- Add the following lines to your config.exs file
```
config :scales_cms,
  endpoint: CmsDemoWeb.Endpoint

config :scales_cms,
  repo: CmsDemo.Repo
```
This will allow the CMS to use your application's endpoint and repo.
- Run the mix tasks that will be released soon to generate migrations

## Development setup
To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
