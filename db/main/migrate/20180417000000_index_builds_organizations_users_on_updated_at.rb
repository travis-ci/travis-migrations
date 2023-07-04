class IndexBuildsOrganizationsUsersOnUpdatedAt < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_builds_on_updated_at ON builds (updated_at)'
    execute 'CREATE INDEX CONCURRENTLY index_users_on_updated_at ON users (updated_at)'
    execute 'CREATE INDEX CONCURRENTLY index_repositories_on_updated_at ON repositories (updated_at)'
    execute 'CREATE INDEX CONCURRENTLY index_organizations_on_updated_at ON organizations (updated_at)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_builds_on_updated_at'
    execute 'DROP INDEX CONCURRENTLY index_users_on_updated_at'
    execute 'DROP INDEX CONCURRENTLY index_repositories_on_updated_at'
    execute 'DROP INDEX CONCURRENTLY index_organizations_on_updated_at'
  end
end
