class AddConstraintsToMultipleTables < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key :repositories, :builds, column: :current_build_id
    add_foreign_key :repositories, :builds, column: :last_build_id

    add_foreign_key :builds, :repositories
    add_foreign_key :builds, :commits
    add_foreign_key :builds, :requests
    add_foreign_key :builds, :pull_requests
    add_foreign_key :builds, :branches
    add_foreign_key :builds, :tags
    add_foreign_key :builds, :build_configs, column: :config_id

    add_foreign_key :jobs, :repositories
    add_foreign_key :jobs, :commits
    add_foreign_key :jobs, :stages
    add_foreign_key :jobs, :job_configs, column: :config_id

    add_foreign_key :branches, :repositories
    add_foreign_key :branches, :builds, column: :last_build_id

    add_foreign_key :tags, :repositories
    add_foreign_key :tags, :builds, column: :last_build_id

    add_foreign_key :commits, :repositories
    add_foreign_key :commits, :branches
    add_foreign_key :commits, :tags

    add_foreign_key :crons, :branches

    add_foreign_key :job_configs, :repositories
    add_foreign_key :build_configs, :repositories
    add_foreign_key :pull_requests, :repositories
    add_foreign_key :ssl_keys, :repositories

    add_foreign_key :requests, :commits
    add_foreign_key :requests, :pull_requests
    add_foreign_key :requests, :branches
    add_foreign_key :requests, :tags
    add_foreign_key :requests, :request_configs, column: :config_id

    add_foreign_key :stages, :builds
  end
end
