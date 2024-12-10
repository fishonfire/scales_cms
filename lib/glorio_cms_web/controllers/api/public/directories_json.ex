defmodule GlorioCmsWeb.Api.Public.DirectoriesJSON do
  def show(%{directory: directory}) do
    %{
      id: directory.id,
      title: directory.title,
      slug: directory.slug,
      directory_id: directory.cms_directory_id
    }
  end
end
