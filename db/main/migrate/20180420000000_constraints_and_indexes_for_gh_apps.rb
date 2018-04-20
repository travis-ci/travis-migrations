class ConstraintsAndIndexesForGhApps < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "ALTER TABLE installations ADD CONSTRAINT unique_github_id_on_installations UNIQUE (github_id)"
    execute "CREATE INDEX CONCURRENTLY index_repositories_on_managed ON repositories (managed_by_installation_at)"
  end

  def down
    execute "ALTER TABLE installations DROP CONSTRAINT unique_github_id_on_installations"
    execute "DROP INDEX CONCURRENTLY index_repositories_on_managed"
  end
end
