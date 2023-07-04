# frozen_string_literal: true

class AddIndexUsersPreferencesBuildEmails < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute <<~SQL
      CREATE INDEX CONCURRENTLY user_preferences_build_emails_false ON users (id) WHERE preferences->>'build_emails' = 'false';
    SQL
  end

  def down
    execute <<~SQL
      DROP INDEX CONCURRENTLY user_preferences_build_emails_false;
    SQL
  end
end
