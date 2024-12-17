defmodule ScalesCmsWeb.CmsRouter do
  @moduledoc """
  The Macros for defining the routes in the main application
  """
  defmacro cms_admin(opts, do: block) do
    scope =
      quote bind_quoted: binding() do
        session_opts = [root_layout: {ScalesCmsWeb.Layouts, :root}]

        if opts[:on_mount] do
          session_opts = Keyword.put_new(session_opts, :on_mount, opts[:on_mount])
        end

        live_session :cms_admin, session_opts do
          scope "/cms", ScalesCmsWeb do
            # cms assets

            # cms routes
            live "/", CmsIndexLive.Index, :index

            live "/directories", CmsDirectoryLive.Index, :index
            live "/directories/new", CmsDirectoryLive.Index, :new
            live "/directories/:id", CmsDirectoryLive.Index, :index
            live "/directories/:id/new", CmsDirectoryLive.Index, :new

            live "/directories/:id/edit", CmsDirectoryLive.Index, :edit

            live "/directories/:id/show/edit", CmsDirectoryLive.Show, :edit

            live "/pages", CmsPageLive.Index, :index
            live "/pages/new", CmsPageLive.Index, :new
            live "/pages/:id/new", CmsPageLive.Index, :new
            live "/pages/:id/edit", CmsPageLive.Index, :edit

            live "/pages/:id", CmsPageLive.Show, :show
            live "/pages/:id/show/edit", CmsPageLive.Show, :edit

            live "/page_variants", CmsPageVariantLive.Index, :index
            live "/page_variants/new", CmsPageVariantLive.Index, :new
            live "/page_variants/:id/edit", CmsPageVariantLive.Index, :edit

            live "/page_variants/:id", CmsPageVariantLive.Show, :show
            live "/page_variants/:id/show/edit", CmsPageVariantLive.Show, :edit

            live "/page_builder/:id", PageBuilderLive.Edit, :edit

            block
          end
        end
      end

    if Code.ensure_loaded?(Phoenix.VerifiedRoutes) do
      quote do
        unquote(scope)
      end
    else
      scope
    end
  end

  defmacro cms_assets() do
    scope =
      quote bind_quoted: binding() do
        scope "/cms", ScalesCmsWeb do
          get "/css-:md5", Plugs.Assets, :css, as: :cms_asset
          get "/js-:md5", Plugs.Assets, :js, as: :cms_asset
        end
      end

    if Code.ensure_loaded?(Phoenix.VerifiedRoutes) do
      quote do
        unquote(scope)
      end
    else
      scope
    end
  end

  defmacro api_public() do
    scope =
      quote bind_quoted: binding() do
        # Other scopes may use custom stacks.
        scope "/public", ScalesCmsWeb.Api.Public do
          get("/pages", PagesController, :index)
          get("/pages/:id", PagesController, :show)
          get("/components", ComponentsController, :index)
        end
      end

    if Code.ensure_loaded?(Phoenix.VerifiedRoutes) do
      quote do
        unquote(scope)
      end
    else
      scope
    end
  end
end
