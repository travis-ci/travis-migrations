# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    create_table 'messages', force: :cascade do |t|
      t.integer 'subject_id'
      t.string 'subject_type'
      t.string 'level'
      t.string 'key'
      t.string 'code'
      t.json 'args'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
    end
    execute 'CREATE INDEX CONCURRENTLY index_messages_on_subject_type_and_subject_id ON messages(subject_type, subject_id)'
  end

  def down
    execute 'DROP INDEX index_messages_on_subject_type_and_subject_id'
    drop_table :messages
  end
end
