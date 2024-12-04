defmodule GlorioCmsWeb.Components.CmsComponents.Helpers.FileUploader do
  @moduledoc """
  A multi use Phoenix LiveView file uploader ready for direct to S3 uploading
  """
  defmacro __using__(opts) do
    entity_name = Keyword.fetch!(opts, :entity_name)

    quote bind_quoted: [entity_name: entity_name] do
      alias GlorioCms.Cms.Helpers.S3Upload

      def file_uploader(var!(assigns)) do
        ~H"""
        <section phx-drop-target={@uploads.image.ref}>
          <.simple_form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
            <.input type="hidden" field={@form[entity_url_as_atom()]} />
            <.input type="hidden" field={@form[entity_path_as_atom()]} />

            <.live_file_input upload={@uploads.image} target={@myself} />

            <:actions>
              <.button phx-disable-with="Saving...">Save image</.button>
            </:actions>
          </.simple_form>

          <%!-- render each file entry --%>
          <%= for entry <- @uploads.image.entries do %>
            <article class="upload-entry">
              <figure>
                <.live_img_preview entry={entry} />
                <figcaption>{entry.client_name}</figcaption>
              </figure>

              <%!-- entry.progress will update automatically for in-flight entries --%>
              <progress value={entry.progress} max="100">{entry.progress}%</progress>

              <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
              <button
                type="button"
                phx-click="cancel-upload"
                phx-value-ref={entry.ref}
                aria-label="cancel"
              >
                &times;
              </button>

              <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
              <%= for err <- upload_errors(@uploads.image, entry) do %>
                <p class="alert alert-danger">{inspect(err)}</p>
              <% end %>
            </article>
          <% end %>

          <%= for err <- upload_errors(@uploads.image) do %>
            <p class="alert alert-danger">{inspect(err)}</p>
          <% end %>
        </section>
        """
      end

      @doc """
      Adds the uploaded file URLs to the block params
      """
      def put_file_urls(socket, block) do
        uploaded_file_urls =
          consume_uploaded_entries(socket, :image, fn _, entry ->
            {:ok, S3Upload.entry_url(entry)}
          end)

        block
        |> Map.put(
          entity_url_as_string(),
          add_file_url_to_params(
            List.first(uploaded_file_urls),
            block[entity_url_as_string()]
          )
        )
        |> Map.put(
          entity_path_as_string(),
          add_file_path_to_params(
            List.first(uploaded_file_urls),
            block[entity_path_as_string()]
          )
        )
      end

      @doc """
      Presigns the S3 upload and returns the key and URL so the user can start the upload
      """
      def presign_entry(entry, %{assigns: %{uploads: uploads}} = socket) do
        {:ok, {key, url}} = S3Upload.presigned_url(entry)

        {:ok, %{uploader: "S3", key: key, url: url}, socket}
      end

      defp add_file_url_to_params(nil, file_url), do: file_url
      defp add_file_url_to_params(s3_url, _file_url), do: s3_url

      defp add_file_path_to_params(nil, file_url), do: file_url

      defp add_file_path_to_params(s3_url, _file_url),
        do: String.replace(s3_url, S3Upload.bucket_path(), "")

      defp entity_url_as_atom(), do: String.to_atom(entity_url_as_string())

      defp entity_url_as_string(), do: "#{unquote(entity_name)}_url"

      defp entity_path_as_atom(), do: String.to_atom(entity_path_as_string())

      defp entity_path_as_string(), do: "#{unquote(entity_name)}_path"
    end
  end
end
