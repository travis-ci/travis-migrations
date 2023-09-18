# frozen_string_literal: true

class BuildsAddIndexState < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_builds_on_state ON builds (state)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_builds_on_state'
  end
end
