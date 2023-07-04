class BuildsAddIndexRepositoryIdAndNumber < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_builds_on_repository_id_and_number ON builds(repository_id, (number::integer))'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_builds_on_repository_id_and_number'
  end
end
