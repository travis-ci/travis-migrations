# frozen_string_literal: true

class JobsDropIndexStateOwnerTypeOwnerId < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'DROP INDEX CONCURRENTLY index_jobs_on_state_owner_type_owner_id'
  end

  def down
    execute 'CREATE INDEX CONCURRENTLY index_jobs_on_state_owner_type_owner_id ON jobs (state, owner_id, owner_type)'
  end
end
