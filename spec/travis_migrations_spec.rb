# frozen_string_literal: true

require 'English'
require 'spec_helper'
require 'yaml'
require 'rake/notes/rake_task'

describe 'Rake tasks' do
  let(:config) { YAML.safe_load(ERB.new(File.read('config/database.yml')).result, aliases: true) }
  let(:conn)   { ActiveRecord::Base.connection }
  let(:tables) { conn.select_values("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'") }

  let(:expected_main_tables) do
    %w[
      abuses
      audits
      beta_features
      beta_migration_requests
      branches
      broadcasts
      build_backups
      build_configs
      builds
      cancellations
      commits
      coupons
      crons
      custom_keys
      deleted_builds
      deleted_stages
      deleted_jobs
      deleted_requests
      deleted_commits
      deleted_pull_requests
      deleted_job_configs
      deleted_build_configs
      deleted_ssl_keys
      deleted_tags
      deleted_request_configs
      deleted_request_payloads
      deleted_request_yaml_configs
      deleted_request_raw_configurations
      deleted_request_raw_configs
      email_unsubscribes
      emails
      gatekeeper_workers
      installations
      invoices
      job_configs
      job_versions
      jobs
      memberships
      messages
      organizations
      owner_groups
      permissions
      pull_requests
      queueable_jobs
      repo_counts
      repositories
      request_configs
      request_payloads
      request_yaml_configs
      request_raw_configs
      request_raw_configurations
      requests
      ssl_keys
      stages
      stars
      stripe_events
      subscriptions
      tags
      tokens
      trial_allowances
      trials
      urls
      user_beta_features
      user_utm_params
      users
      ar_internal_metadata
      schema_migrations
    ]
  end

  before { ActiveRecord::Base.establish_connection(config['test']) }
  after { ActiveRecord::Base.remove_connection }

  def run(cmd)
    system "RAILS_ENV=test bundle exec #{cmd}  > migration.log"
    expect($CHILD_STATUS.exitstatus).to eq 0
  end

  describe 'rake db:create' do
    it 'migrates the main db' do
      run 'rake db:drop db:create db:migrate'
      expect(tables.sort).to eq expected_main_tables.sort
    end
  end

  describe 'rake db:schema:load' do
    it 'loads the main schema' do
      run 'rake db:drop db:create db:schema:load'
      expect(tables.sort).to eq expected_main_tables.sort
    end
  end
end
