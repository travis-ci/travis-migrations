# frozen_string_literal: true

class AddIndexToJobVersionsOnJobId < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :job_versions, :job_id, algorithm: :concurrently
  end
end
