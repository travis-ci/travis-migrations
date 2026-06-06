class AddIdxRepositoriesOwnerIdType < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index :repositories, %i[owner_id owner_type],
              algorithm: :concurrently,
              name: 'idx_repositories_owner_id_type',
              if_not_exists: true
  end

  def down
    remove_index :repositories, name: 'idx_repositories_owner_id_type', if_exists: true
  end
end
