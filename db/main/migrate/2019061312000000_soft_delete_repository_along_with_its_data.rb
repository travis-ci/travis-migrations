class SoftDeleteRepositoryAlongWithItsData < ActiveRecord::Migration[5.2]
  def up
    execute "create table deleted_builds (like builds)"
    execute "create table deleted_branches (like branches)"
    execute "create table deleted_stages (like stages)"
    execute "create table deleted_jobs (like jobs)"
    execute "create table deleted_requests (like requests)"
    execute "create table deleted_commits (like commits)"
    execute "create table deleted_pull_requests (like pull_requests)"
    execute "create table deleted_crons (like crons)"
    execute "create table deleted_job_configs (like job_configs)"
    execute "create table deleted_build_configs (like build_configs)"
    execute "create table deleted_request_configs (like request_configs)"
    execute "create table deleted_request_payloads (like request_payloads)"
    execute "create table deleted_ssl_keys (like ssl_keys)"
    execute "create table deleted_tags (like tags)"

    execute File.read(Rails.root.join('db/main/sql/create_soft_delete_repo_data.sql'))
  end

  def down
    execute "drop table deleted_builds"
    execute "drop table deleted_branches"
    execute "drop table deleted_stages"
    execute "drop table deleted_jobs"
    execute "drop table deleted_requests"
    execute "drop table deleted_commits"
    execute "drop table deleted_pull_requests"
    execute "drop table deleted_crons"
    execute "drop table deleted_job_configs"
    execute "drop table deleted_build_configs"
    execute "drop table deleted_request_configs"
    execute "drop table deleted_request_payloads"
    execute "drop table deleted_ssl_keys"
    execute "drop table deleted_tags"

    execute File.read(Rails.root.join('db/main/sql/drop_soft_delete_repo_data.sql'))
  end
end
