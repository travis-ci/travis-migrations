class AddIdxRepositoriesOwner < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index :repositories, %i[owner_type owner_id],
              algorithm: :concurrently,
              name: 'idx_repositories_owner',
              if_not_exists: true
  end

  def down
    remove_index :repositories, name: 'idx_repositories_owner', if_exists: true
  end
end
