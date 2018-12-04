require 'spec_helper'
require 'yaml'

describe 'set_updated_at trigger' do
  def run(cmd)
    system "RAILS_ENV=test bundle exec #{cmd}"
    expect($?.exitstatus).to eq 0
  end

  let(:config) { YAML.load(ERB.new(File.read('config/database.yml')).result) }
  before(:all) do
    run 'rake db:drop db:create db:migrate'
  end

  before { ActiveRecord::Base.establish_connection(config['test']) }
  after { ActiveRecord::Base.remove_connection }

  before do
    conn.execute('TRUNCATE branches CASCADE;')
  end

  let(:conn)   { ActiveRecord::Base.connection }

  def e(query)
    conn.execute(query)
  end

  def s(query)
    conn.select_one(query)
  end

  it 'sets unique_name on INSERT' do
    e "INSERT INTO repositories (id, created_at, updated_at) VALUES(1, now(), now())"
    e "INSERT INTO branches (repository_id, name, created_at, updated_at) VALUES (1, 'main', now(), now());"
    result = s "SELECT name FROM branches"
    expect(result['name']).to eql('main')
  end

  it 'sets unique_name on UPDATE' do
    e "INSERT INTO repositories (id, created_at, updated_at) VALUES(1, now(), now())"
    e "INSERT INTO branches (repository_id, name, created_at, updated_at) VALUES (1, 'main', now(), now());"
    e "UPDATE branches SET name = 'foo';"
    result = s "SELECT unique_name FROM branches"
    expect(result['unique_name']).to eql('foo')
  end

  it 'enforces the index' do
    e "INSERT INTO repositories (id, created_at, updated_at) VALUES(1, now(), now())"
    e "INSERT INTO branches (repository_id, name, created_at, updated_at) VALUES (1, 'main', now(), now());"
    expect {
    e "INSERT INTO branches (repository_id, name, created_at, updated_at) VALUES (1, 'main', now(), now());"
    }.to raise_error(ActiveRecord::RecordNotUnique)

    e "INSERT INTO branches (repository_id, name, created_at, updated_at) VALUES (1, 'something-else', now(), now());"
    expect {
      e "UPDATE branches SET name = 'main';"
    }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
