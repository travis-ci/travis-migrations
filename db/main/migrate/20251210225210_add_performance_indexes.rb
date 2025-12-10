class AddPerformanceIndexes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    # Primary Tables - Core entity tables
    add_index :builds, [:owner_type, :owner_id, :created_at],
              algorithm: :concurrently,
              name: 'idx_builds_owner_created',
              if_not_exists: true

    add_index :jobs, [:owner_type, :owner_id, :created_at],
              algorithm: :concurrently,
              name: 'idx_jobs_owner_created',
              if_not_exists: true

    add_index :requests, [:owner_type, :owner_id, :created_at],
              algorithm: :concurrently,
              name: 'idx_requests_owner_created',
              if_not_exists: true

    add_index :repositories, [:owner_type, :owner_id],
              algorithm: :concurrently,
              name: 'idx_repositories_owner',
              if_not_exists: true

    # Related tables with foreign keys
    add_index :commits, [:repository_id, :created_at],
              algorithm: :concurrently,
              name: 'idx_commits_repo_created',
              if_not_exists: true

    add_index :pull_requests, [:repository_id, :created_at],
              algorithm: :concurrently,
              name: 'idx_pull_requests_repo_created',
              if_not_exists: true

    add_index :request_payloads, [:request_id, :created_at],
              algorithm: :concurrently,
              name: 'idx_request_payloads_request_created',
              if_not_exists: true

    add_index :custom_image_logs, [:custom_image_id, :created_at],
              algorithm: :concurrently,
              name: 'idx_custom_image_logs_image_created',
              if_not_exists: true

    add_index :build_backups, [:repository_id, :created_at],
              algorithm: :concurrently,
              name: 'idx_build_backups_repo_created',
              if_not_exists: true

    # Config tables
    add_index :jobs, [:repository_id, :created_at, :config_id],
              algorithm: :concurrently,
              name: 'idx_jobs_repo_created_config',
              if_not_exists: true

    add_index :builds, [:repository_id, :created_at, :config_id],
              algorithm: :concurrently,
              name: 'idx_builds_repo_created_config',
              if_not_exists: true

    add_index :requests, [:repository_id, :created_at, :config_id],
              algorithm: :concurrently,
              name: 'idx_requests_repo_created_config',
              if_not_exists: true

    # Child record tables
    add_index :job_states, [:job_id],
              algorithm: :concurrently,
              name: 'idx_job_states_job',
              if_not_exists: true

    add_index :job_versions, [:job_id],
              algorithm: :concurrently,
              name: 'idx_job_versions_job',
              if_not_exists: true

    add_index :stages, [:build_id],
              algorithm: :concurrently,
              name: 'idx_stages_build',
              if_not_exists: true

    # Deleted record tables
    add_index :deleted_builds, [:owner_type, :owner_id, :created_at],
              algorithm: :concurrently,
              name: 'idx_deleted_builds_owner_created',
              if_not_exists: true

    add_index :deleted_jobs, [:owner_type, :owner_id, :created_at],
              algorithm: :concurrently,
              name: 'idx_deleted_jobs_owner_created',
              if_not_exists: true

    add_index :deleted_requests, [:owner_type, :owner_id, :created_at],
              algorithm: :concurrently,
              name: 'idx_deleted_requests_owner_created',
              if_not_exists: true

    add_index :deleted_commits, [:repository_id, :created_at],
              algorithm: :concurrently,
              name: 'idx_deleted_commits_repo_created',
              if_not_exists: true

    add_index :deleted_pull_requests, [:repository_id, :created_at],
              algorithm: :concurrently,
              name: 'idx_deleted_pull_requests_repo_created',
              if_not_exists: true
  end

  def down
    # Remove indexes in reverse order
    remove_index :deleted_pull_requests, name: 'idx_deleted_pull_requests_repo_created', if_exists: true
    remove_index :deleted_commits, name: 'idx_deleted_commits_repo_created', if_exists: true
    remove_index :deleted_requests, name: 'idx_deleted_requests_owner_created', if_exists: true
    remove_index :deleted_jobs, name: 'idx_deleted_jobs_owner_created', if_exists: true
    remove_index :deleted_builds, name: 'idx_deleted_builds_owner_created', if_exists: true
    
    remove_index :stages, name: 'idx_stages_build', if_exists: true
    remove_index :job_versions, name: 'idx_job_versions_job', if_exists: true
    remove_index :job_states, name: 'idx_job_states_job', if_exists: true
    
    remove_index :requests, name: 'idx_requests_repo_created_config', if_exists: true
    remove_index :builds, name: 'idx_builds_repo_created_config', if_exists: true
    remove_index :jobs, name: 'idx_jobs_repo_created_config', if_exists: true
    
    remove_index :build_backups, name: 'idx_build_backups_repo_created', if_exists: true
    remove_index :custom_image_logs, name: 'idx_custom_image_logs_image_created', if_exists: true
    remove_index :request_payloads, name: 'idx_request_payloads_request_created', if_exists: true
    remove_index :pull_requests, name: 'idx_pull_requests_repo_created', if_exists: true
    remove_index :commits, name: 'idx_commits_repo_created', if_exists: true
    
    remove_index :repositories, name: 'idx_repositories_owner', if_exists: true
    remove_index :requests, name: 'idx_requests_owner_created', if_exists: true
    remove_index :jobs, name: 'idx_jobs_owner_created', if_exists: true
    remove_index :builds, name: 'idx_builds_owner_created', if_exists: true
  end
end
