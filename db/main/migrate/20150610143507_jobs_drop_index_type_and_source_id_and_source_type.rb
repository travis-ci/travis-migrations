# frozen_string_literal: true

class JobsDropIndexTypeAndSourceIdAndSourceType < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'DROP INDEX CONCURRENTLY index_jobs_on_type_and_owner_id_and_owner_type' if index_exists?(:jobs, :index_jobs_on_type_and_owner_id_and_owner_type)
  end

  def down
    execute 'CREATE INDEX CONCURRENTLY index_jobs_on_type_and_source_id_and_source_type ON jobs (type, source_id, source_type)'
  end
end
