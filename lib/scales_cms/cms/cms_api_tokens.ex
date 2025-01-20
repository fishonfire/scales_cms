defmodule ScalesCms.Cms.CmsApiTokens do
  @moduledoc """
  The CMS API Keys context.
  """

  import Ecto.Query, warn: false
  alias ScalesCms.Cms.CmsApiToken
  import ScalesCms, only: [repo: 0]

  @doc """
  Returns the most recent API token.
  """
  def get_most_recent_api_token do
    CmsApiToken
    |> order_by(desc: :inserted_at)
    |> limit(1)
    |> repo().one()
  end

  @doc """
  Creates a cms_page.

  ## Examples

      iex> create_cms_api_token(%{field: value})
      {:ok, %CmsApiToken{}}

      iex> create_cms_api_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cms_api_token(attrs \\ %{}) do
    attrs = Map.put(attrs, :token, generate_token())

    %CmsApiToken{}
    |> CmsApiToken.changeset(attrs)
    |> repo().insert()
  end

  defp generate_token do
    claims = %{
      "typ" => "access",
      "exp" => nil,
      "sub" => "cms_api_token"
    }

    {:ok, jwt, _claims} = ScalesCms.Guardian.encode_and_sign("app", claims)

    jwt
  end

  @doc """
  Updates a cms_api_token.

  ## Examples

      iex> update_cms_api_token(cms_api_token, %{token: new_value})
      {:ok, %CmsApiToken{}}

      iex> update_cms_api_token(cms_api_token, %{token: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def update_cms_api_token(%CmsApiToken{} = cms_api_token, attrs) do
    cms_api_token
    |> CmsApiToken.changeset(attrs)
    |> repo().update()
  end

  @doc """
  Deletes a cms_api_token.

  ## Examples

      iex> delete_cms_api_token(cms_api_token)
      {:ok, %CmsApiToken{}}

      iex> delete_cms_api_token(cms_api_token)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cms_api_token(%CmsApiToken{} = cms_api_token) do
    repo().delete(cms_api_token)
  end
end
