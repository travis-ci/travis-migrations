class RepositoriesAddIndexName < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_repositories_on_name ON repositories(name)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_repositories_on_name"
  end
end
