# frozen_string_literal: true

class CreateIndexOnBranchesUniqueNameAndRepositoryId < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_branches_repository_id_unique_name ON branches(repository_id, unique_name) WHERE unique_name IS NOT NULL'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY IF EXISTS index_branches_repository_id_unique_name'
  end
end
