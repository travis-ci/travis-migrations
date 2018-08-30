require 'spec_helper'
require 'yaml'

describe 'Rake tasks' do
  let(:config) { YAML.load(ERB.new(File.read('config/database.yml')).result) }
  let(:conn)   { ActiveRecord::Base.connection }
  let(:tables) { conn.select_values("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'") }

  let(:expected_main_tables) do
    %w(
      abuses
      beta_features
      branches
      broadcasts
      build_configs
      builds
      cancellations
      commits
      coupons
      crons
      email_unsubscribes
      emails
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
      users
      ar_internal_metadata
      schema_migrations
    )
  end

  before { ActiveRecord::Base.establish_connection(config['test']) }
  after { ActiveRecord::Base.remove_connection }

  def run(cmd)
    system "RAILS_ENV=test bundle exec #{cmd}"
    expect($?.exitstatus).to eq 0
  end

  describe 'rake db:create' do
    it 'migrates the main db' do
      run 'rake db:drop db:create db:migrate'
      expect(tables.sort).to eq expected_main_tables.sort
    end
  end

  describe 'rake db:structure:load' do
    it 'loads the main schema'do
      run 'rake db:drop db:create db:structure:load'
      expect(tables.sort).to eq expected_main_tables.sort
    end
  end
end
