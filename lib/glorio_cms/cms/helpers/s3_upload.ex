defmodule GlorioCms.Cms.Helpers.S3Upload do
  def entry_filename(entry), do: "#{entry.uuid}_#{entry.client_name}"

  def entry_url(entry),
    do: "http://#{bucket()}.s3.#{region()}.amazonaws.com/public/#{entry_filename(entry)}"

  def bucket_path(), do: "http://#{bucket()}.s3.#{region()}.amazonaws.com/"

  def presigned_url(entry) do
    config = ExAws.Config.new(:s3)
    key = "public/#{entry_filename(entry)}"

    {:ok, url} =
      ExAws.S3.presigned_url(config, :put, bucket(), key,
        expires_in: 3600,
        query_params: [{"Content-Type", entry.client_type}]
      )

    {:ok, {key, url}}
  end

  def bucket(), do: ExAws.Config.new(:s3)[:bucket_name]

  def region(), do: ExAws.Config.new(:s3)[:region]

  def get_presigned_url_for_display(key) do
    config = ExAws.Config.new(:s3)
    {:ok, url} = ExAws.S3.presigned_url(config, :get, bucket(), key, expires_in: 3600)
    url
  end
end
