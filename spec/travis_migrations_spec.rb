require 'spec_helper'
require 'yaml'


describe 'Rake tasks' do
  let(:config) { YAML.load(ERB.new(File.read('config/database.yml')).result) }
  let(:conn)   { ActiveRecord::Base.connection }
  let(:main_tables) { conn.select_values("SELECT table_name FROM information_schema.tables WHERE table_catalog = 'main' AND table_schema = 'public'") }
  let(:logs_tables) { conn.select_values("SELECT table_name FROM information_schema.tables WHERE table_catalog = 'logs' AND table_schema = 'public'") }
  before       { ActiveRecord::Base.establish_connection(config['test']) }

  def run(cmd, env_str = '')
    system "RAILS_ENV=test #{env_str} bundle exec #{cmd}"
    expect($?.exitstatus).to eq 0
  end

  shared_examples_for 'creates the expected main tables' do
    it 'creates the expected tables' do
      expect(main_tables.sort).to eq %w(
        schema_migrations tokens users builds repositories commits requests
        ssl_keys memberships urls permissions jobs broadcasts emails
        organizations annotation_providers annotations branches stars
        crons subscriptions plans coupons stripe_events invoices
      ).sort
    end
  end

  shared_examples_for 'creates the expected logs tables' do
    it 'creates the expected tables' do
      expect(logs_tables.sort).to eq %w(
        schema_migrations logs log_parts
      ).sort
    end
  end

  describe 'rake db:create' do
    before { run 'rake db:drop db:create db:migrate', 'DATABASE_NAME=main' }
    include_examples 'creates the expected main tables'
  end

  describe 'rake db:schema:load' do
    before { run 'rake db:drop db:create db:structure:load', 'DATABASE_NAME=main' }
    include_examples 'creates the expected main tables'
  end

  describe 'rake db:create logs database' do
    before { run 'rake db:drop db:create db:migrate', 'DATABASE_NAME=logs LOGS_DATABASE=1' }
    include_examples 'creates the expected logs tables'
  end

  describe 'rake db:schema:load logs database' do
    before { run 'rake db:drop db:create db:structure:load', 'DATABASE_NAME=logs LOGS_DATABASE=1' }
    include_examples 'creates the expected logs tables'
  end
end
