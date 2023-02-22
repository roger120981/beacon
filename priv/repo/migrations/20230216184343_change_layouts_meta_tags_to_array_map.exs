defmodule Beacon.Repo.Migrations.ChangeLayoutsMetaTagsToArrayMap do
  use Ecto.Migration

  def up do
    # temporary column to hold transformed meta tags
    alter table(:beacon_layouts) do
      add :array_meta_tags, {:array, :map}
    end

    layout_meta_tags = """
      SELECT id, meta_tags AS old_meta_tags FROM beacon_layouts
    """

    types = %{id: :binary_id, old_meta_tags: :map}
    result = repo().query!(layout_meta_tags)

    unless result.rows do
      # for each row, query old meta tags, transform it, and store the transformed values as array
      for row <- result.rows do
        %{id: id, old_meta_tags: old_meta_tags} = repo().load(types, {result.columns, row})
        {:ok, id} = Ecto.UUID.dump(id)

        new_meta_tags =
          Enum.map(old_meta_tags, fn {key, value} ->
            %{"name" => key, "content" => value}
          end)

        execute(fn ->
          repo().query!(
            """
            UPDATE beacon_layouts
               SET array_meta_tags = $1
             WHERE id = $2
            """,
            [new_meta_tags, id],
            log: :info
          )
        end)
      end
    end

    # remove old meta tags
    alter table(:beacon_layouts) do
      remove :meta_tags
    end

    # make the new column the current meta tags value
    rename table(:beacon_layouts), :array_meta_tags, to: :meta_tags
  end

  # do nothing
  def down do
  end
end