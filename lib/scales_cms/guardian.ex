defmodule ScalesCms.Guardian do
  @moduledoc """
    Guardian Implementation to resolve module to user
  """
  use Guardian, otp_app: :scales_cms

  def subject_for_token(_resource, _claims) do
    {:ok, "app"}
  end

  def resource_from_claims(%{"sub" => _id}) do
    resource = nil
    {:ok, resource}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
