# ScalesCms
ScalesCMS is a plugin CMS for [`the Phoenix Framework`](https://www.phoenixframework.org/) that is developed by [`Fish on Fire`](https://fishonfire.nl)
and allows you to manage the content of either applications or websites easily.

It provides a set of JSON endpoints for headless usage. Alongside the CMS we also provide a set of
[`React Native`](https://reactnative.dev/) components that can be used to easily integrate the CMS into your application.

## Prerequisites
- Elixir 1.14
- Phoenix 1.7.17 and higher

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

## React Native Renderer
More info on https://github.com/fishonfire/react-native-scales-renderer

## Development setup
To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Contributors
- Simon de la Court (https://github.com/simondelacourt)
- Alexey Pikulik (https://github.com/alexeyfof)

## Copyright and Licence
Copyright (c) 2024, Fish on Fire.

Phoenix source code is licensed under the [`GPL License`](https://github.com/fishonfire/scales_cms/blob/develop/LICENSE).
