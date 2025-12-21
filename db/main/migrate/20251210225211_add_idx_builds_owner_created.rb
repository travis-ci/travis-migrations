class AddIdxBuildsOwnerCreated < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index :builds, %i[owner_type owner_id created_at],
              algorithm: :concurrently,
              name: 'idx_builds_owner_created',
              if_not_exists: true
  end

  def down
    remove_index :builds, name: 'idx_builds_owner_created', if_exists: true
  end
end
