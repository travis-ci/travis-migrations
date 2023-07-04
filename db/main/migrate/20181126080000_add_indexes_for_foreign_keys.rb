class AddIndexesForForeignKeys < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index :builds, :branch_id, algorithm: :concurrently
    add_index :builds, :commit_id, algorithm: :concurrently
    add_index :builds, :pull_request_id, algorithm: :concurrently
    add_index :builds, :tag_id, algorithm: :concurrently
    add_index :jobs, :commit_id, algorithm: :concurrently
    add_index :branches, :last_build_id, algorithm: :concurrently
    add_index :tags, :repository_id, algorithm: :concurrently
    add_index :tags, :last_build_id, algorithm: :concurrently
    add_index :commits, :tag_id, algorithm: :concurrently
    add_index :commits, :branch_id, algorithm: :concurrently
    add_index :job_configs, :repository_id, algorithm: :concurrently
    add_index :build_configs, :repository_id, algorithm: :concurrently
    add_index :pull_requests, :repository_id, algorithm: :concurrently
    add_index :requests, :pull_request_id, algorithm: :concurrently
    add_index :requests, :tag_id, algorithm: :concurrently
    add_index :requests, :branch_id, algorithm: :concurrently
    add_index :repositories, :current_build_id, algorithm: :concurrently
    add_index :repositories, :last_build_id, algorithm: :concurrently
    add_index :crons, :branch_id, algorithm: :concurrently
  end

  def down
    remove_index :builds, :branch_id
    remove_index :builds, :commit_id
    remove_index :builds, :pull_request_id
    remove_index :builds, :tag_id
    remove_index :jobs, :commit_id
    remove_index :branches, :last_build_id
    remove_index :tags, :repository_id
    remove_index :tags, :last_build_id
    remove_index :commits, :tag_id
    remove_index :commits, :branch_id
    remove_index :job_configs, :repository_id
    remove_index :build_configs, :repository_id
    remove_index :pull_requests, :repository_id
    remove_index :requests, :pull_request_id
    remove_index :requests, :tag_id
    remove_index :requests, :branch_id
    remove_index :repositories, :current_build_id
    remove_index :repositories, :last_build_id
    remove_index :crons, :branch_id
  end

  def add_index(table, column, options = {})
    unless index_exists?(table, column)
      super(table, column, **options)
    end
  end
end
