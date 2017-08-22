class CreateRequestMessages < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    create_table "request_messages", force: :cascade do |t|
      t.string "level"
      t.string "key"
      t.string "code"
      t.jsonb "args"
      t.integer "request_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    execute "CREATE INDEX CONCURRENTLY index_request_messages_on_request_id ON request_messages(request_id)"
  end

  def down
    execute "DROP INDEX index_request_messages_on_request_id"
    drop_table :request_messages
  end
end
