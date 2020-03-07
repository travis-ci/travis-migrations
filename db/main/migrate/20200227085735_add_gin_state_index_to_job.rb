class AddGinStateIndexToJob < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    execute "CREATE INDEX CONCURRENTLY index_jobs_on_state_gin ON jobs USING gin(state gin_trgm_ops)"
  end
end
