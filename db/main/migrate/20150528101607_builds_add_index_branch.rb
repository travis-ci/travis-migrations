class BuildsAddIndexBranch < ActiveRecord::Migration[4.2]
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_builds_on_branch ON builds (branch)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_builds_on_branch"
  end
end
