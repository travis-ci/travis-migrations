# frozen_string_literal: true

class AddUniqueIndexToCronsOnBranchId < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'DROP INDEX CONCURRENTLY index_crons_on_branch_id'
    execute 'CREATE UNIQUE INDEX CONCURRENTLY index_crons_on_branch_id ON crons(branch_id)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_crons_on_branch_id'
  end
end
