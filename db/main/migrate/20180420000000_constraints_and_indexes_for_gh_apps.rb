class ConstraintsAndIndexesForGhApps < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE UNIQUE INDEX CONCURRENTLY github_id_installations_idx ON installations (github_id)"
    execute "CREATE INDEX CONCURRENTLY managed_repositories_idx ON repositories (managed_by_installation_at)"
    execute "CREATE UNIQUE INDEX CONCURRENTLY owner_installations_idx ON installations (owner_id, owner_type) WHERE removed_by_id IS NULL"
  end

  def down
    execute "DROP INDEX CONCURRENTLY github_id_installations_idx"
    execute "DROP INDEX CONCURRENTLY managed_repositories_idx"
    execute "DROP INDEX CONCURRENTLY owner_removed_installations_idx"
    execute "DROP INDEX CONCURRENTLY owner_installations_idx"
  end
end
