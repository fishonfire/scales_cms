defmodule ScalesCmsWeb.CmsRouter do
  @moduledoc """
  Macros for defining CMS routes in the host application.
  """

  defmacro cms_admin(opts \\ [], do: block) do
    existing_hooks =
      opts
      |> Keyword.get(:on_mount, [])
      |> List.wrap()
      |> Enum.map(&expand_on_mount_hook(&1, __CALLER__))

    all_hooks =
      existing_hooks ++
        [
          {ScalesCmsWeb.Hooks.SidebarState, :default},
          {ScalesCmsWeb.SaveRequestUri, :save_request_uri}
        ]

    session_opts = [
      root_layout: {ScalesCmsWeb.Layouts, :root},
      on_mount: all_hooks,
      session: {ScalesCmsWeb.Hooks.SidebarState, :copy_session, []}
    ]

    quote do
      live_session :cms_admin, unquote(Macro.escape(session_opts)) do
        scope "/cms", ScalesCmsWeb do
          get "/stats", CmsStatsController, :index

          live "/", CmsIndexLive.Index, :index
          live "/settings", CmsSettingsLive.Index, :index

          live "/directories", CmsDirectoryLive.Index, :index
          live "/directories/:id", CmsDirectoryLive.Index, :index

          live "/pages", CmsPageLive.Index, :index
          live "/pages/:id", CmsPageLive.Show, :show
          live "/pages/:id/show/edit", CmsPageLive.Show, :edit

          live "/page_variants", CmsPageVariantLive.Index, :index
          live "/page_variants/:id", CmsPageVariantLive.Show, :show
          live "/page_variants/:id/show/edit", CmsPageVariantLive.Show, :edit

          live "/page_builder/:id", PageBuilderLive.Edit, :edit
          live "/page_builder/:id/edit", PageBuilderLive.Edit, :edit_variant

          live "/media", CmsMediaLibraryLive.Index, :index
        end

        scope "/" do
          unquote(block)
        end
      end
    end
  end

  defp expand_on_mount_hook({module_ast, arg}, env) do
    {Macro.expand(module_ast, env), arg}
  end

  defp expand_on_mount_hook(module_ast, env) do
    Macro.expand(module_ast, env)
  end

  defmacro cms_assets do
    quote do
      scope "/cms", ScalesCmsWeb do
        get "/css-:md5", Plugs.Assets, :css, as: :cms_asset
        get "/js-:md5", Plugs.Assets, :js, as: :cms_asset
      end
    end
  end

  defmacro api_public do
    quote do
      scope "/public", ScalesCmsWeb.Api.Public do
        get "/pages", PagesController, :index
        get "/pages/:id", PagesController, :show
        get "/pages/slug/:slug", PagesController, :show
        get "/components", ComponentsController, :index
      end
    end
  end
end
