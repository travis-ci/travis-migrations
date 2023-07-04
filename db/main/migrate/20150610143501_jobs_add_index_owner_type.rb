# frozen_string_literal: true

class JobsAddIndexOwnerType < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_jobs_on_owner_type ON jobs (owner_type)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_jobs_on_owner_type'
  end
end
