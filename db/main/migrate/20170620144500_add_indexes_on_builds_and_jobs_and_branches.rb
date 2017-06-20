class AddIndexesOnBuildsAndJobsAndBranches < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_builds_on_repository_id_and_branch_and_id_desc ON builds (repository_id, branch, id DESC)"
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_owner_id_and_owner_type_and_state ON jobs (owner_id, owner_type, state)"
    execute "CREATE INDEX CONCURRENTLY index_branches_on_repository_id ON branches (repository_id)"
  end

  def down
    execute "DROP INDEX CONCURRENTLY index_builds_on_repository_id_and_branch_and_id_desc"
    execute "DROP INDEX CONCURRENTLY index_jobs_on_owner_id_and_owner_type_and_state"
    execute "DROP INDEX CONCURRENTLY index_branches_on_repository_id"
  end
end
