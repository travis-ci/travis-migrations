class AddRepositoryNameAndSlugIndex < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_repositories_on_slug_or_names ON repositories (vcs_slug, owner_name, name) WHERE invalidated_at IS NULL"
  end
end
