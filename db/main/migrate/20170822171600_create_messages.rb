class CreateMessages < ActiveRecord::Migration
  self.disable_ddl_transaction!

  def up
    create_table "messages", force: :cascade do |t|
      t.integer "subject_id"
      t.string "subject_type"
      t.string "level"
      t.string "key"
      t.string "code"
      t.jsonb "args"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    execute "CREATE INDEX CONCURRENTLY index_messages_on_subject_type ON messages(subject_type)"
  end

  def down
    execute "DROP INDEX index_messages_on_subject_type"
    drop_table :messages
  end
end
