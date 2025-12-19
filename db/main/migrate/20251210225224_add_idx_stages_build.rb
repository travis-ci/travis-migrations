class AddIdxStagesBuild < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index :stages, [:build_id],
              algorithm: :concurrently,
              name: 'idx_stages_build',
              if_not_exists: true
  end

  def down
    remove_index :stages, name: 'idx_stages_build', if_exists: true
  end
end
