# frozen_string_literal: true

class AddIndexOnBuildState < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!
  def up
    execute <<-SQL
      CREATE INDEX CONCURRENTLY index_builds_on_state
        ON builds(state);
    SQL
  end

  def down
    execute 'DROP INDEX index_builds_on_state'
  end
end
