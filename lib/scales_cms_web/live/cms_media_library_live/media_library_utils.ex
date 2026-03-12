defmodule ScalesCmsWeb.CmsMediaLibraryLive.MediaLibraryUtils do
  @moduledoc """
  Shared utility functions for the CMS Media Library.
  Contains common logic used by both the Index and Modal components.
  """

  use Gettext,
    backend: ScalesCmsWeb.Gettext

  alias ScalesCms.Cms.CmsMediaLibrary

  @max_entries 10
  @max_file_size 25_000_000

  @type_definitions %{
    image: %{
      extensions: ~w(.png .jpeg .jpg .webp),
      display_names: ~w(PNG JPEG JPG WEBP)
    },
    video: %{
      extensions: ~w(.mp4 .webm .mov),
      display_names: ~w(MP4 WEBM MOV)
    },
    lottie: %{
      extensions: ~w(.json),
      display_names: ["JSON (Lottie)"]
    }
  }

  @all_accepted_types Enum.flat_map(@type_definitions, fn {_type, %{extensions: exts}} -> exts end)

  @doc """
  Returns upload configuration options for allow_upload.
  """
  def upload_config do
    %{
      max_entries: @max_entries,
      max_file_size: @max_file_size
    }
  end

  @doc """
  Returns the accepted file types based on the filter type.
  """
  def get_accepted_types(nil), do: @all_accepted_types

  def get_accepted_types(type) when is_binary(type) do
    case Map.get(@type_definitions, String.to_existing_atom(type)) do
      %{extensions: exts} -> exts
      nil -> @all_accepted_types
    end
  rescue
    ArgumentError -> @all_accepted_types
  end

  @doc """
  Returns a human-readable string of supported formats based on the filter type.
  Generated dynamically from the accepted types definitions.
  """
  def supported_formats_text(nil) do
    all_display_names =
      @type_definitions
      |> Enum.flat_map(fn {_type, %{display_names: names}} -> names end)
      |> Enum.join(", ")

    gettext("Supported formats: %{formats}", formats: all_display_names)
  end

  def supported_formats_text(type) when is_binary(type) do
    case Map.get(@type_definitions, String.to_existing_atom(type)) do
      %{display_names: names} ->
        gettext("Supported formats: %{formats}", formats: Enum.join(names, ", "))

      nil ->
        supported_formats_text(nil)
    end
  rescue
    ArgumentError -> supported_formats_text(nil)
  end

  @doc """
  Converts a client MIME type to a media type string.
  """
  def get_media_type(client_type) do
    cond do
      String.starts_with?(client_type, "image/") -> "image"
      String.starts_with?(client_type, "video/") -> "video"
      client_type == "application/json" -> "lottie"
      true -> "image"
    end
  end

  @doc """
  Lists media items based on query and type filters.
  """
  def list_media_items("", ""), do: CmsMediaLibrary.list_media_library_items()
  def list_media_items("", type), do: CmsMediaLibrary.list_media_library_items_by_type(type)
  def list_media_items(query, ""), do: CmsMediaLibrary.search_media_library_items(query)
  def list_media_items(query, type), do: CmsMediaLibrary.search_media_library_items(query, type)

  @doc """
  Converts an upload error atom to a human-readable error message.
  """
  def upload_error_to_string(:too_large), do: gettext("The file is too large")
  def upload_error_to_string(:too_many_files), do: gettext("You have selected too many files")

  def upload_error_to_string(:not_accepted),
    do: gettext("You have selected an unacceptable file type")

  def upload_error_to_string(:external_client_failure),
    do: gettext("Something went wrong uploading the file")

  def upload_error_to_string(_), do: gettext("An error occurred")

  @doc """
  Returns the CSS classes for a media type badge.
  """
  def type_badge_class("image"),
    do: "bg-gray-100 text-gray-800"

  def type_badge_class("video"),
    do: "bg-red-100 text-red-800"

  def type_badge_class("lottie"),
    do: "bg-purple-100 text-purple-800"

  def type_badge_class(_),
    do: "bg-gray-100 text-gray-800"
end
