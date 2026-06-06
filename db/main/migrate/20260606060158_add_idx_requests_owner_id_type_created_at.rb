class AddIdxRequestsOwnerIdTypeCreatedAt < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index :requests, %i[owner_id owner_type created_at],
              algorithm: :concurrently,
              name: 'idx_requests_owner_id_type_created_at',
              if_not_exists: true
  end

  def down
    remove_index :requests, name: 'idx_requests_owner_id_type_created_at', if_exists: true
  end
end
