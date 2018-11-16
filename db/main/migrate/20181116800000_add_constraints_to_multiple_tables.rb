class AddConstraintsToMultipleTables < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key :repositories, :builds, column: :current_build_id, on_delete: :nullify
    add_foreign_key :repositories, :builds, column: :last_build_id, on_delete: :nullify

    add_foreign_key :builds, :repositories, on_delete: :cascade
    add_foreign_key :builds, :commits, on_delete: :cascade
    add_foreign_key :builds, :requests, on_delete: :cascade
    add_foreign_key :builds, :pull_requests, on_delete: :cascade
    add_foreign_key :builds, :branches, on_delete: :cascade
    add_foreign_key :builds, :tags, on_delete: :cascade
    add_foreign_key :builds, :build_configs, column: :config_id, on_delete: :cascade

    add_foreign_key :jobs, :repositories, on_delete: :cascade
    add_foreign_key :jobs, :commits, on_delete: :cascade
    add_foreign_key :jobs, :stages, on_delete: :cascade
    add_foreign_key :jobs, :job_configs, column: :config_id, on_delete: :cascade

    add_foreign_key :branches, :repositories, on_delete: :cascade
    add_foreign_key :branches, :builds, column: :last_build_id, on_delete: :nullify

    add_foreign_key :tags, :repositories, on_delete: :cascade
    add_foreign_key :tags, :builds, column: :last_build_id, on_delete: :nullify

    add_foreign_key :commits, :repositories, on_delete: :cascade
    add_foreign_key :commits, :branches, on_delete: :cascade
    add_foreign_key :commits, :tags, on_delete: :cascade

    add_foreign_key :crons, :branches, on_delete: :cascade

    add_foreign_key :job_configs, :repositories, on_delete: :cascade
    add_foreign_key :build_configs, :repositories, on_delete: :cascade
    add_foreign_key :pull_requests, :repositories, on_delete: :cascade
    add_foreign_key :ssl_keys, :repositories, on_delete: :cascade

    add_foreign_key :requests, :commits, on_delete: :cascade
    add_foreign_key :requests, :pull_requests, on_delete: :cascade
    add_foreign_key :requests, :branches, on_delete: :cascade
    add_foreign_key :requests, :tags, on_delete: :cascade
    add_foreign_key :requests, :request_configs, column: :config_id, on_delete: :cascade

    add_foreign_key :stages, :builds, on_delete: :cascade
  end
end
