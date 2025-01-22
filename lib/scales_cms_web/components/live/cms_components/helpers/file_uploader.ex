defmodule ScalesCmsWeb.Components.CmsComponents.Helpers.FileUploader do
  @moduledoc """
  A multi use Phoenix LiveView file uploader ready for direct to S3 uploading
  """
  defmacro __using__(opts) do
    entity_name = Keyword.fetch!(opts, :entity_name)

    quote bind_quoted: [entity_name: entity_name] do
      alias ScalesCms.Cms.Helpers.S3Upload

      def file_uploader(var!(assigns)) do
        ~H"""
        <% upload = Map.get(@uploads, String.to_atom(@entity_name)) %>
        <section phx-drop-target={upload.ref} class="flex border-2 border-dashed p-[16px]">
          <.simple_form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
            <.input
              type="hidden"
              field={@form[entity_url_as_atom()]}
              id={
                if @id,
                  do: "#{@id}-#{@entity_name}-_properties_image_url",
                  else: "#{@entity_name}-_properties_image_url"
              }
            />

            <.input
              type="hidden"
              field={@form[entity_path_as_atom()]}
              id={
                if @id,
                  do: "#{@id}-#{@entity_name}-_properties_image_path",
                  else: "#{@entity_name}-_properties_image_path"
              }
            />

            <.live_file_input upload={upload} target={@myself} />

            <%!-- render each file entry --%>
            <article :for={entry <- upload.entries} class="upload-entry mt-[24px] bg-slate-100">
              <div class="p-[8px]">
                <figure>
                  <.live_img_preview
                    entry={entry}
                    class="max-w-[200px] max-h-[200px] object-cover mr-[24px]"
                  />
                  <figcaption>{entry.client_name}</figcaption>
                </figure>

                <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
                <p :for={err <- upload_errors(upload, entry)} class="alert alert-danger">
                  {upload_error_to_string(err)}
                </p>
              </div>
              <div class="w-full bg-slate-200 border-t-2 p-[8px] flex justify-between">
                <%!-- entry.progress will update automatically for in-flight entries --%>
                <progress value={entry.progress} max="100" class="flex-1 bg-slate-400">
                  {entry.progress}%
                </progress>

                <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
                <button
                  type="button"
                  phx-click="cancel-upload"
                  phx-target={@myself}
                  phx-value-ref={entry.ref}
                  aria-label="cancel"
                  class="ml-[8px] bg-red-500 text-white px-[8px] rounded"
                >
                  &times;
                </button>
                <button
                  :if={Enum.count(upload.entries) > 0}
                  phx-disable-with={gettext("..")}
                  phx-submit="save"
                  class="ml-[8px] bg-green-500 text-white px-[8px] rounded"
                >
                  <.icon name="hero-check" class="h-[16px] w-[16px]" />
                </button>
              </div>
            </article>
          </.simple_form>

          <p :for={err <- upload_errors(upload)} class="alert alert-danger">{inspect(err)}</p>
        </section>
        """
      end

      @impl Phoenix.LiveComponent
      def handle_event("cancel-upload", %{"ref" => ref, "value" => _}, socket) do
        {:noreply, cancel_upload(socket, String.to_atom(unquote(entity_name)), ref)}
      end

      @doc """
      Adds the uploaded file URLs to the block params
      """
      def put_file_urls(socket, block) do
        uploaded_file_urls =
          consume_uploaded_entries(socket, String.to_atom(unquote(entity_name)), fn _, entry ->
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

      defp upload_error_to_string(:too_large), do: gettext("The file is too large")

      defp upload_error_to_string(:not_accepted),
        do: gettext("You have selected an unacceptable file type")

      defp upload_error_to_string(:external_client_failure),
        do: gettext("Something went terribly wrong")

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
