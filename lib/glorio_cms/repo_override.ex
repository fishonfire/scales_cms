defmodule GlorioCms.RepoOverride do
  defmacro __using__(_) do
    [repo | _] = Application.get_env(:glorio_cms, :ecto_repos)

    quote do
      alias unquote(repo), as: Repo
    end
  end
end
