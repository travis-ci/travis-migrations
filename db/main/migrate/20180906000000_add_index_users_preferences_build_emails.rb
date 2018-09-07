class AddIndexUsersPreferencesBuildEmails < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute <<~sql
      CREATE INDEX CONCURRENTLY user_preferences_build_emails_false ON users (id) WHERE preferences->>'build_emails' = 'false';
    sql
  end

  def down
    execute <<~sql
      DROP INDEX CONCURRENTLY user_preferences_build_emails_false;
    sql
  end
end


