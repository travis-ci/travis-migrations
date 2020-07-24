class AddReposIndexOnLowerOwnerNameAndName < ActiveRecord::Migration
    self.disable_ddl_transaction!
  
    def up
      execute 'CREATE INDEX CONCURRENTLY index_repositories_on_lower_owner_name_and_name ON repositories (LOWER(owner_name), LOWER(name)) WHERE invalidated_at IS NULL'
    end
  
    def down
      execute 'DROP INDEX CONCURRENTLY IF EXISTS index_repositories_on_lower_owner_name_and_name'
    end
  end