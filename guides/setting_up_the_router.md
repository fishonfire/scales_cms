# Setting up the router
ScalesCMS provides a macro to inject the CMS routes into your applications router.
The usage is simple, just add the following to your router;

```elixir
defmodule CmsDemoWeb.Router do
  use CmsDemoWeb, :router

  # < ...>

  import ScalesCmsWeb.CmsRouter

  # < ...>

  # adapt the api pipeline to provide the api version
  pipeline :api do
    plug :accepts, ["json"]
    plug(ScalesCmsWeb.Plugs.ApiVersion)
  end

  # < ...>

  scope "/" do
    pipe_through [:browser, :require_authenticated_user]

    cms_admin(on_mount: [{CmsDemoWeb.UserAuth, :ensure_authenticated}]) do
      # custom routes
    end
  end

  # < ...>

  # setup the api routes

  scope "/api" do
    pipe_through :api

    api_public()
  end

end
```

In this example the router is connected to the `CmsDemoWeb.UserAuth` module, which is responsible for ensuring that the user is authenticated before accessing the CMS admin interface.
This is based on the Phoenix default authentication generator.

## Custom routes
You can provide your own custom routes. These can be inserted into the do block. This automatically sets up the layout so it will be part of the CMS admin.
