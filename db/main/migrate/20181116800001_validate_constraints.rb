class ValidateConstraints < ActiveRecord::Migration[4.2]
  def up
    execute "ALTER TABLE repositories VALIDATE CONSTRAINT fk_repositories_on_current_build_id"
    execute "ALTER TABLE repositories VALIDATE CONSTRAINT fk_repositories_on_last_build_id"
    execute "ALTER TABLE builds VALIDATE CONSTRAINT fk_builds_on_repository_id"
    execute "ALTER TABLE builds VALIDATE CONSTRAINT fk_builds_on_commit_id"
    execute "ALTER TABLE builds VALIDATE CONSTRAINT fk_builds_on_request_id"
    execute "ALTER TABLE builds VALIDATE CONSTRAINT fk_builds_on_pull_request_id"
    execute "ALTER TABLE builds VALIDATE CONSTRAINT fk_builds_on_branch_id"
    execute "ALTER TABLE builds VALIDATE CONSTRAINT fk_builds_on_tag_id"
    execute "ALTER TABLE builds VALIDATE CONSTRAINT fk_builds_on_config_id"
    execute "ALTER TABLE jobs VALIDATE CONSTRAINT fk_jobs_on_repository_id"
    execute "ALTER TABLE jobs VALIDATE CONSTRAINT fk_jobs_on_commit_id"
    execute "ALTER TABLE jobs VALIDATE CONSTRAINT fk_jobs_on_stage_id"
    execute "ALTER TABLE jobs VALIDATE CONSTRAINT fk_jobs_on_config_id"
    execute "ALTER TABLE branches VALIDATE CONSTRAINT fk_branches_on_repository_id"
    execute "ALTER TABLE branches VALIDATE CONSTRAINT fk_branches_on_last_build_id"
    execute "ALTER TABLE tags VALIDATE CONSTRAINT fk_tags_on_repository_id"
    execute "ALTER TABLE tags VALIDATE CONSTRAINT fk_tags_on_last_build_id"
    execute "ALTER TABLE commits VALIDATE CONSTRAINT fk_commits_on_repository_id"
    execute "ALTER TABLE commits VALIDATE CONSTRAINT fk_commits_on_branch_id"
    execute "ALTER TABLE commits VALIDATE CONSTRAINT fk_commits_on_tag_id"
    execute "ALTER TABLE crons VALIDATE CONSTRAINT fk_crons_on_branch_id"
    execute "ALTER TABLE job_configs VALIDATE CONSTRAINT fk_job_configs_on_repository_id"
    execute "ALTER TABLE build_configs VALIDATE CONSTRAINT fk_build_configs_on_repository_id"
    execute "ALTER TABLE pull_requests VALIDATE CONSTRAINT fk_pull_requests_on_repository_id"
    execute "ALTER TABLE ssl_keys VALIDATE CONSTRAINT fk_ssl_keys_on_repository_id"
    execute "ALTER TABLE requests VALIDATE CONSTRAINT fk_requests_on_commit_id"
    execute "ALTER TABLE requests VALIDATE CONSTRAINT fk_requests_on_pull_request_id"
    execute "ALTER TABLE requests VALIDATE CONSTRAINT fk_requests_on_branch_id"
    execute "ALTER TABLE requests VALIDATE CONSTRAINT fk_requests_on_tag_id"
    execute "ALTER TABLE requests VALIDATE CONSTRAINT fk_requests_on_config_id"
    execute "ALTER TABLE stages VALIDATE CONSTRAINT fk_stages_on_build_id"
  end
end
