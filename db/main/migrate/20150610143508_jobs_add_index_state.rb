# frozen_string_literal: true

class JobsAddIndexState < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_jobs_on_state ON jobs (state)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_jobs_on_state'
  end
end
