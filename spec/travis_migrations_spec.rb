require 'spec_helper'
require 'yaml'

describe 'Rake tasks' do
  let(:config) { YAML.load(ERB.new(File.read('config/database.yml')).result) }
  let(:conn)   { ActiveRecord::Base.connection }
  let(:tables) { conn.select_values("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'") }
  let(:expected_main_tables) { %w(
    schema_migrations tokens users builds repositories commits requests
    ssl_keys memberships urls permissions jobs broadcasts emails features
    organizations annotation_providers annotations branches stars
    crons subscriptions plans coupons stripe_events invoices
    )
  }
  let(:expected_logs_tables){ %w(
    schema_migrations logs log_parts
    )
  }

  def run(cmd)
    system "RAILS_ENV=test bundle exec #{cmd}"
    expect($?.exitstatus).to eq 0
  end

  def run_logs(cmd)
    system "RAILS_ENV=test_logs bundle exec #{cmd}"
    expect($?.exitstatus).to eq 0
  end

  describe 'rake db:create' do
    it 'migrates the logs db' do
      run_logs 'rake db:drop db:create db:migrate'
      ActiveRecord::Base.establish_connection(config['test_logs'])
      expect(tables.sort).to eq expected_logs_tables.sort
    end
    it 'migrates the main db' do
      run 'rake db:drop db:create db:migrate'
      ActiveRecord::Base.establish_connection(config['test'])
      expect(tables.sort).to eq expected_main_tables.sort
    end
  end

  describe 'rake db:schema:load' do
    it 'loads the logs schema' do
      run_logs 'rake db:drop db:create db:structure:load'
      ActiveRecord::Base.establish_connection(config['test_logs'])
      expect(tables.sort).to eq expected_logs_tables.sort
    end
    it 'loads the main schema'do
    run 'rake db:drop db:create db:structure:load'
    ActiveRecord::Base.establish_connection(config['test'])
      expect(tables.sort).to eq expected_main_tables.sort
    end
  end
end
