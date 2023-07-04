class AddVcsIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_repositories_on_lower_slug_or_on_lower_owner_name ON repositories (LOWER(vcs_slug), LOWER(owner_name), LOWER(name), LOWER(vcs_type)) WHERE invalidated_at IS NULL'
  end
end
