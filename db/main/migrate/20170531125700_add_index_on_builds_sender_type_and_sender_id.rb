class AddIndexOnBuildsSenderTypeAndSenderId < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_builds_on_sender_type_and_sender_id ON builds (sender_type, sender_id);'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_builds_on_sender_type_and_sender_id'
  end
end
