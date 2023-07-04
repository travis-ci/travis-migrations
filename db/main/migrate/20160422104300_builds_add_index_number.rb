class BuildsAddIndexNumber < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_builds_on_number ON builds (number)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_builds_on_number'
  end
end
