require 'spec_helper'
require 'yaml'

describe 'Rake tasks' do
  let(:config) { YAML.load(ERB.new(File.read('config/database.yml')).result) }
  let(:conn)   { ActiveRecord::Base.connection }
  let(:tables) { conn.select_values("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'") }
  let(:expected_main_tables) { %w(
    schema_migrations tokens users builds repositories commits requests
    ssl_keys memberships urls permissions jobs broadcasts emails beta_features
    user_beta_features organizations annotation_providers annotations branches
    stars crons subscriptions coupons stripe_events invoices queueable_jobs
    pull_requests stages owner_groups tags trials messages trial_allowances abuses
    )
  }

  before do
    ActiveRecord::Base.establish_connection(config['test'])
  end

  after do
    ActiveRecord::Base.remove_connection
  end

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

  describe 'rake db:schema:load' do
    it 'loads the main schema'do
      run 'rake db:drop db:create db:structure:load'
      expect(tables.sort).to eq expected_main_tables.sort
    end
  end
end
