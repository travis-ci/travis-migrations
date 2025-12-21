class AddIdxJobVersionsJob < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index :job_versions, [:job_id],
              algorithm: :concurrently,
              name: 'idx_job_versions_job',
              if_not_exists: true
  end

  def down
    remove_index :job_versions, name: 'idx_job_versions_job', if_exists: true
  end
end
