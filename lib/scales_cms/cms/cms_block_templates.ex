defmodule ScalesCms.Cms.CmsBlockTemplates do
  @moduledoc """
  The Cms context.
  """

  import Ecto.Query, warn: false
  alias ScalesCms.Cms.CmsBlockTemplate
  alias ScalesCms.Cms.CmsPageVariants
  import ScalesCms, only: [repo: 0]

  @doc """
  Returns the list of cms_block_templates.

  ## Examples

      iex> list_cms_block_templates()
      [%CmsBlockTemplate{}, ...]

  """
  def list_cms_block_templates do
    repo().all(CmsBlockTemplate)
  end

  def list_cms_block_templates(locale) do
    CmsBlockTemplate
    |> scope_on_locale(locale)
    |> repo().all()
  end

  @doc """
  Gets a single cms_block_template.

  Raises `Ecto.NoResultsError` if the Cms page variant block does not exist.

  ## Examples

      iex> get_cms_block_template!(123)
      %CmsBlockTemplate{}

      iex> get_cms_block_template!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cms_block_template!(id), do: repo().get!(CmsBlockTemplate, id)

  def get_by_family_and_locale(template_family_id, locale) do
    CmsBlockTemplate
    |> where([t], t.template_family_id == ^template_family_id)
    |> where([t], t.locale == ^locale)
    |> repo().one()
  end

  def get_or_create_localized_variant!(%CmsBlockTemplate{} = template, locale) do
    case get_by_family_and_locale(template.template_family_id, locale) do
      nil ->
        create_localized_variant!(template, locale)

      localized_template ->
        localized_template
    end
  end

  def create_localized_variant!(%CmsBlockTemplate{} = template, locale) do
    attrs = %{
      name: template.name,
      component_type: template.component_type,
      properties: template.properties,
      locale: locale,
      template_family_id: template.template_family_id,
      published_at: template.published_at
    }

    %CmsBlockTemplate{}
    |> CmsBlockTemplate.changeset(attrs)
    |> repo().insert!()
  end

  @doc """
  Creates a cms_block_template.

  ## Examples

      iex> create_cms_block_template(%{field: value})
      {:ok, %CmsBlockTemplate{}}

      iex> create_cms_block_template(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cms_block_template(attrs \\ %{}) do
    %CmsBlockTemplate{}
    |> CmsBlockTemplate.changeset(attrs)
    |> repo().insert()
  end

  @doc """
  Updates a cms_block_template.

  ## Examples

      iex> update_cms_block_template(cms_block_template, %{field: new_value})
      {:ok, %CmsBlockTemplate{}}

      iex> update_cms_block_template(cms_block_template, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cms_block_template(%CmsBlockTemplate{} = cms_block_template, attrs) do
    cms_block_template
    |> CmsBlockTemplate.changeset(attrs)
    |> repo().update()
  end

  @doc """
  Deletes a cms_block_template.

  ## Examples

      iex> delete_cms_block_template(cms_block_template)
      {:ok, %CmsBlockTemplate{}}

      iex> delete_cms_block_template(cms_block_template)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cms_block_template(%CmsBlockTemplate{} = cms_block_template) do
    repo().delete(cms_block_template)
  end

  @doc """
  Adds embedded element in a cms_block_template by embedded field name.

  ## Examples

      iex> add_cms_block_template_embedded_element(cms_block_template, "buttons")
      {:ok, %CmsBlockTemplate{}}

      iex> add_cms_block_template_embedded_element(cms_block_template)
      {:error, %Ecto.Changeset{}}

  """
  def add_cms_block_template_embedded_element(
        %CmsBlockTemplate{} = cms_block_template,
        embedded_field
      ) do
    buttons = Map.get(cms_block_template.properties, embedded_field, []) ++ [%{}]

    update_cms_block_template(cms_block_template, %{
      properties: Map.merge(cms_block_template.properties, %{embedded_field => buttons})
    })
  end

  @doc """
  Deletes embedded element in a cms_block_template by embedded field name and index.

  ## Examples

      iex> delete_cms_block_template_embedded_element(cms_block_template, "buttons", "0")
      {:ok, %CmsBlockTemplate{}}

      iex> delete_cms_block_template_embedded_element(cms_block_template)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cms_block_template_embedded_element(
        %CmsBlockTemplate{} = cms_block_template,
        embedded_field,
        embedded_index
      ) do
    buttons =
      Map.get(cms_block_template.properties, embedded_field, [])
      |> List.delete_at(String.to_integer(embedded_index))

    update_cms_block_template(cms_block_template, %{
      properties: Map.merge(cms_block_template.properties, %{embedded_field => buttons})
    })
  end

  def delete_blocks_for_cms_templates(template_ids) do
    CmsBlockTemplate
    |> where([pvb], pvb.cms_template_id in ^template_ids)
    |> repo().delete_all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cms_block_template changes.

  ## Examples

      iex> change_cms_block_template(cms_block_template)
      %Ecto.Changeset{data: %CmsBlockTemplate{}}

  """
  def change_cms_block_template(%CmsBlockTemplate{} = cms_block_template, attrs \\ %{}) do
    CmsBlockTemplate.changeset(cms_block_template, attrs)
  end

  @doc """
  Applies sorting to a query based on the given column and order.

  ## Parameters

    * `query` - The Ecto query to sort
    * `sort_by` - Column to sort by: "created"
    * `sort_order` - Sort direction: "asc" or "desc" (default: "asc")

  ## Examples

      iex> apply_sorting(query, "created", "desc")
      #Ecto.Query<...>

  """
  def apply_sorting(query, sort_by, sort_order) do
    cond do
      sort_by == "updated" && sort_order == "desc" ->
        query |> order_by([cd], desc: cd.updated_at)

      sort_by == "updated" ->
        query |> order_by([cd], asc: cd.updated_at)

      sort_by == "created" && sort_order == "desc" ->
        query |> order_by([cd], desc: cd.inserted_at)

      sort_by == "created" ->
        query |> order_by([cd], asc: cd.inserted_at)

      true ->
        query
    end
  end

  @doc """
  Fetches a list of cms block templates based on parameters
  """
  def fetch_cms_block_templates(query, offset, limit, opts \\ [])

  def fetch_cms_block_templates("", offset, limit, opts) do
    CmsBlockTemplate
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> scope_on_locale(opts[:locale])
    |> limit(^limit)
    |> offset(^offset)
    |> repo().all()
  end

  def fetch_cms_block_templates(query, offset, limit, opts) do
    CmsBlockTemplate
    |> where([cd], ilike(cd.name, ^"%#{query}%"))
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> scope_on_locale(opts[:locale])
    |> limit(^limit)
    |> offset(^offset)
    |> repo().all()
  end

  @doc """
  Counts block_templates with optional search query.
  Used for root-level directory listing pagination.

  ## Examples

      iex> count_block_templates("")
      10

  """
  def count_block_templates(query \\ "")

  def count_block_templates("") do
    CmsBlockTemplate
    |> select([cd], count(cd.id))
    |> repo().one()
  end

  def count_block_templates(query) do
    CmsBlockTemplate
    |> where([cd], ilike(cd.name, ^"%#{query}%"))
    |> select([cd], count(cd.id))
    |> repo().one()
  end

  def scope_on_locale(query, locale) do
    query |> where([cd], ilike(cd.locale, ^"%#{locale}%"))
  end

  def get_for_page_variant(template_family_id, page_variant_id) do
    page_variant = CmsPageVariants.get_cms_page_variant!(page_variant_id)

    CmsBlockTemplate
    |> where(
      [t],
      t.template_family_id == ^template_family_id and t.locale == ^page_variant.locale
    )
    |> repo().one()
  end

  def publish_cms_block_template(cms_block_template) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    {count, nil} =
      CmsBlockTemplate
      |> where([t], t.template_family_id == ^cms_block_template.template_family_id)
      |> repo().update_all(set: [published_at: now])

    case count do
      0 -> {:error, "Did not update anything"}
      _ -> {:ok, get_cms_block_template!(cms_block_template.id)}
    end
  end

  def delete_cms_block_templates_by_template_family_id(template_family_id) do
    {count, nil} =
      CmsBlockTemplate
      |> where([t], t.template_family_id == ^template_family_id)
      |> repo().delete_all()

    case count do
      0 -> {:error, "Did not delete anything"}
      _ -> {:ok, "OK"}
    end
  end
end
