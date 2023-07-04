require 'spec_helper'
require 'yaml'

describe 'set_updated_at trigger' do
  def run(cmd)
    system "RAILS_ENV=test bundle exec #{cmd} > migration.log"
    expect($?.exitstatus).to eq 0
  end

  let(:config) { YAML.load(ERB.new(File.read('config/database.yml')).result, aliases: true) }
  before(:all) do
    run 'rake db:drop db:create db:migrate'
  end

  before { ActiveRecord::Base.establish_connection(config['test']) }
  after { ActiveRecord::Base.remove_connection }

  before do
    conn.execute('TRUNCATE builds CASCADE;')
    conn.execute('TRUNCATE jobs CASCADE;')
  end

  let(:conn)   { ActiveRecord::Base.connection }

  def e(query)
    conn.execute(query)
  end

  def s(query)
    conn.select_one(query)
  end

  describe 'jobs' do
    it 'sets updated_at on INSERT' do
      e "INSERT INTO jobs (number, created_at) VALUES ('10.1', now());"
      result = s "SELECT id, updated_at FROM jobs"
      expect(result['updated_at']).to_not be_nil
    end

    it 'sets updated_at on UPDATE' do
      e "INSERT INTO jobs (number, created_at) VALUES ('10.1', now());"
      after_insert = s "SELECT id, updated_at FROM jobs"
      e "UPDATE jobs SET number = '11.1';"
      after_update = s "SELECT id, updated_at FROM jobs"

      expect(after_insert['id']).to eql(after_update['id'])
      expect(after_insert['updated_at']).to_not eql(after_update['updated_at'])

      # now update without any changes, trigger should not fire
      e "UPDATE jobs SET number = '11.1';"
      after_2nd_update = s "SELECT id, updated_at FROM jobs"

      expect(after_2nd_update['id']).to eql(after_update['id'])
      expect(after_2nd_update['updated_at']).to eql(after_update['updated_at'])
    end

    it 'works also for new columns' do
      e "INSERT INTO jobs (number, created_at) VALUES ('10.1', now());"
      after_insert = s "SELECT id, updated_at FROM jobs"

      e "alter table jobs add column foo integer not null default 0;"

      e "UPDATE jobs SET foo = 1;"
      after_update = s "SELECT id, updated_at FROM jobs"

      expect(after_insert['id']).to eql(after_update['id'])
      expect(after_insert['updated_at']).to_not eql(after_update['updated_at'])
    end
  end

  describe 'builds' do
    it 'sets updated_at on INSERT' do
      e "INSERT INTO builds (number, created_at) VALUES ('10', now());"
      result = s "SELECT id, updated_at FROM builds"
      expect(result['updated_at']).to_not be_nil
    end

    it 'sets updated_at on UPDATE' do
      e "INSERT INTO builds (number, created_at) VALUES ('10', now());"
      after_insert = s "SELECT id, updated_at FROM builds"
      e "UPDATE builds SET number = '11';"
      after_update = s "SELECT id, updated_at FROM builds"

      expect(after_insert['id']).to eql(after_update['id'])
      expect(after_insert['updated_at']).to_not eql(after_update['updated_at'])

      # now update without any changes, trigger should not fire
      e "UPDATE builds SET number = '11';"
      after_2nd_update = s "SELECT id, updated_at FROM builds"

      expect(after_2nd_update['id']).to eql(after_update['id'])
      expect(after_2nd_update['updated_at']).to eql(after_update['updated_at'])
    end

    it 'works also for new columns' do
      e "INSERT INTO builds (number, created_at) VALUES (10, now());"
      after_insert = s "SELECT id, updated_at FROM builds"

      e "alter table builds add column foo integer not null default 0;"

      e "UPDATE builds SET foo = 1;"
      after_update = s "SELECT id, updated_at FROM builds"

      expect(after_insert['id']).to eql(after_update['id'])
      expect(after_insert['updated_at']).to_not eql(after_update['updated_at'])
    end

  end
end
