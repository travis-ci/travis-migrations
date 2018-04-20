class ConstraintsAndIndexesForGhApps < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "ALTER TABLE installations ADD CONSTRAINT unique_github_id_on_installations UNIQUE (github_id)"
    execute "CREATE INDEX CONCURRENTLY index_repositories_on_managed ON repositories (managed_by_installation_at)"
    execute "CREATE UNIQUE INDEX CONCURRENTLY favo_3col_uni_idx ON installations (owner_id, owner_type, removed_by_id) WHERE removed_by_id IS NOT NULL"
    execute "CREATE UNIQUE INDEX favo_2col_uni_idx ON installations (owner_id, owner_type) WHERE removed_by_id IS NULL"
  end

  def down
    execute "ALTER TABLE installations DROP CONSTRAINT unique_github_id_on_installations"
    execute "DROP INDEX CONCURRENTLY index_repositories_on_managed"
    execute "DROP INDEX CONCURRENTLY favo_3col_uni_idx"
    execute "DROP INDEX CONCURRENTLY favo_2col_uni_idx"
  end
end
