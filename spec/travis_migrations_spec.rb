require 'spec_helper'
require 'yaml'


describe 'Rake tasks' do
  let(:config) { YAML.load(ERB.new(File.read('config/database.yml')).result) }
  let(:conn)   { ActiveRecord::Base.connection }
  let(:tables) { conn.select_values("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'") }
  before       { ActiveRecord::Base.establish_connection(config['test']) }

  def run(cmd)
    system "RAILS_ENV=test bundle exec #{cmd}"
    expect($?.exitstatus).to eq 0
  end

  shared_examples_for 'creates the expected tables' do
    it 'creates the expected tables' do
      expect(tables.sort).to eq %w(
        schema_migrations tokens users builds repositories commits requests
        ssl_keys memberships urls permissions jobs broadcasts emails logs
        log_parts organizations annotation_providers annotations branches stars
        crons subscriptions plans coupons stripe_events invoices
      ).sort
    end
  end

  describe 'rake db:create' do
    before { run 'rake db:drop db:create db:migrate' }
    include_examples 'creates the expected tables'

  end

  describe 'rake db:schema:load' do
    before { run 'rake db:drop db:create db:structure:load' }
    include_examples 'creates the expected tables'
  end
end
