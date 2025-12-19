class AddIdxRequestPayloadsRequestCreated < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index :request_payloads, %i[request_id created_at],
              algorithm: :concurrently,
              name: 'idx_request_payloads_request_created',
              if_not_exists: true
  end

  def down
    remove_index :request_payloads, name: 'idx_request_payloads_request_created', if_exists: true
  end
end
