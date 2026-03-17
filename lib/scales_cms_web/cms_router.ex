defmodule ScalesCmsWeb.CmsRouter do
  @moduledoc """
  Macros for defining CMS routes in the host application.

  Configuration:

      config :scales_cms,
        enabled_sidebar: true,
        custom_persistence_states: [:filters_open]

  This results in persisted UI states like:

    * `:sidebar_open` when `enabled_sidebar` is true
    * any additional states listed in `:custom_persistence_states`
  """

  defmacro cms_admin(opts \\ [], do: block) do
    existing_hooks =
      opts
      |> Keyword.get(:on_mount, [])
      |> List.wrap()
      |> Enum.map(&expand_on_mount_hook(&1, __CALLER__))

    quote do
      @scales_cms_enabled_sidebar Application.compile_env(:scales_cms, :enabled_sidebar, true)
      @scales_cms_custom_persistence_states Application.compile_env(
                                              :scales_cms,
                                              :custom_persistence_states,
                                              []
                                            )

      scales_cms_persisted_state_names =
        (if(@scales_cms_enabled_sidebar, do: [:sidebar_open], else: []) ++
           List.wrap(@scales_cms_custom_persistence_states))
        |> Enum.uniq()

      scales_cms_persisted_state_hooks =
        Enum.map(scales_cms_persisted_state_names, fn name ->
          default =
            case name do
              :sidebar_open -> true
              _ -> false
            end

          {ScalesCmsWeb.Hooks.PersistedState,
           [
             name: name,
             session_key: Atom.to_string(name),
             default: default
           ]}
        end)

      scales_cms_session_keys =
        Enum.map(scales_cms_persisted_state_names, &Atom.to_string/1)

      scales_cms_all_hooks =
        unquote(Macro.escape(existing_hooks)) ++
          scales_cms_persisted_state_hooks ++
          [
            {ScalesCmsWeb.SaveRequestUri, :save_request_uri},
            {ScalesCmsWeb.Hooks.ContextMenu, :default}
          ]

      scales_cms_session_opts = [
        root_layout: {ScalesCmsWeb.Layouts, :root},
        on_mount: scales_cms_all_hooks,
        session: {ScalesCmsWeb.Hooks.PersistedState, :copy_session, [scales_cms_session_keys]}
      ]

      live_session :cms_admin, scales_cms_session_opts do
        scope "/cms", ScalesCmsWeb do
          get "/stats", CmsStatsController, :index

          live "/", CmsIndexLive.Index, :index
          live "/settings", CmsSettingsLive.Index, :index

          live "/directories", CmsDirectoryLive.Index, :index
          live "/directories/:id", CmsDirectoryLive.Index, :index

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

        scope "/ui", ScalesCmsWeb do
          post "/state", PersistedStateController, :update
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
