# ScalesCms
ScalesCMS is a plugin CMS for [`the Phoenix Framework`](https://www.phoenixframework.org/) that is developed by [`Fish on Fire`](https://fishonfire.nl)
and allows you to manage the content of either applications or websites easily.

It provides a set of JSON endpoints for headless usage. Alongside the CMS we also provide a set of
[`React Native`](https://reactnative.dev/) components that can be used to easily integrate the CMS into your application.

## Build Status
[![Build Status](https://fishonfire.semaphoreci.com/badges/scales_cms/branches/develop.svg?key=7946eb60-cfc0-4501-b4f6-ae33f17fe39b)](https://fishonfire.semaphoreci.com/projects/scales_cms)

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

## Setup tailwind for the admin interface
- Add `tailwind` to your list of dependencies in `mix.exs`
- Run `mix tailwind.install` to install tailwind
- Add the following lines to your `config.exs` file
```
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]
```
- Create a `tailwind.config.js` file in the root of your project with the following content:
```
// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/scales_cms_web.ex",
    "../lib/scales_cms_web/**/*.*ex"
  ],
  theme: {
    extend: {
      fontFamily: {
        'sans': ['"Poppins"', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        primary: "#21C39D",
        primary_dark: "#178B70",
        secondary: "#0C2136",
        secondary_light: "#0F172A80",
        black: "#151519",
        midGrey: "#4D5D74",
        lightGrey: "#E7EAEE",
        white: "#FFFFFF",
        purple: "#C711B8",
        yellow: "#FFBB34",
        blue: "#36A1FF",
      }
    },
  },
  plugins: [
    require('flowbite/plugin'),
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) }
        })
      })
      matchComponents({
        "hero": ({ name, fullPath }) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, { values })
    })
  ]
}
```
- Create a `css` folder in the `assets` folder and create an `app.css` file with the following content:
```@tailwind base;
@tailwind components;
@tailwind utilities;

/* Import the scales_cms Tailwind CSS file */
@import "../../deps/scales_cms/priv/tailwind/scales_cms.css";

/* This file is for your main application CSS */
```

## React Native Renderer
More info on https://github.com/fishonfire/react-native-scales-renderer

## Development setup
### Prerequisites:
#### **direnv** is used to manage environment variables. You can install it by running:
  1. `curl -sfL https://direnv.net/install.sh | bash`
  2. `echo 'eval "$(direnv hook bash)"' >> ~/.bashrc` or `echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc`
  3. Restart your terminal or run `source ~/.bashrc` or `source ~/.zshrc`

To start your Phoenix server:

  * Run `mix guardian.gen.secret` to generate API secret
  * Set the API secret in the `.envrc` file like this: 
     > export API_SECRET_KEY=+wUAu+Hizgp+rIBZdK8wM2HKYkHT1V6PvrYEoGJybMeH7/VqerwfF8Inw1Cq083W
  * Run `direnv allow` to load the environment variables
  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Contributors
- Simon de la Court (https://github.com/simondelacourt)
- Alexey Pikulik (https://github.com/alexeyfof)
- Menno Jongejan (https://github.com/mennolpFoF)

## Copyright and Licence
Copyright (c) 2024, Fish on Fire.

Phoenix source code is licensed under the [`GPL License`](https://github.com/fishonfire/scales_cms/blob/develop/LICENSE).
