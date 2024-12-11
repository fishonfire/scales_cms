defmodule ScalesCmsWeb.CmsRouter do
  @moduledoc """
  The Macros for defining the routes in the main application
  """
  defmacro cms_admin() do
    scope =
      quote bind_quoted: binding() do
        import Phoenix.LiveView.Router, only: [live: 3, live_session: 3]

        live_session :cms, root_layout: {ScalesCmsWeb.Layouts, :root} do
          scope "/cms", ScalesCmsWeb do
            # cms assets
            get "/css-:md5", Plugs.Assets, :css, as: :cms_asset
            get "/js-:md5", Plugs.Assets, :js, as: :cms_asset

            # cms routes
            live "/", CmsIndexLive.Index, :index

            live "/cms_directories", CmsDirectoryLive.Index, :index
            live "/cms_directories/new", CmsDirectoryLive.Index, :new
            live "/cms_directories/:id", CmsDirectoryLive.Index, :index
            live "/cms_directories/:id/new", CmsDirectoryLive.Index, :new

            live "/cms_directories/:id/edit", CmsDirectoryLive.Index, :edit

            live "/cms_directories/:id/show/edit", CmsDirectoryLive.Show, :edit

            live "/cms_pages", CmsPageLive.Index, :index
            live "/cms_pages/new", CmsPageLive.Index, :new
            live "/cms_pages/:id/new", CmsPageLive.Index, :new
            live "/cms_pages/:id/edit", CmsPageLive.Index, :edit

            live "/cms_pages/:id", CmsPageLive.Show, :show
            live "/cms_pages/:id/show/edit", CmsPageLive.Show, :edit

            live "/cms_page_variants", CmsPageVariantLive.Index, :index
            live "/cms_page_variants/new", CmsPageVariantLive.Index, :new
            live "/cms_page_variants/:id/edit", CmsPageVariantLive.Index, :edit

            live "/cms_page_variants/:id", CmsPageVariantLive.Show, :show
            live "/cms_page_variants/:id/show/edit", CmsPageVariantLive.Show, :edit

            live "/cms_page_builder/:id", PageBuilderLive.Edit, :edit
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
