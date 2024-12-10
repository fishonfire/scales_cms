defmodule GlorioCmsWeb.Api.Public.ComponentsJSON do
  def index(%{components: components, api_version: api_version}) do
    %{
      api_version: api_version,
      components: Enum.map(components, &show(%{component: &1, api_version: api_version}))
    }
  end

  def show(%{component: {type, component}}) do
    %{
      type: type,
      version: component.version(),
      title: component.title(),
      description: component.description()
    }
  end
end
