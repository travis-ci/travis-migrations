# frozen_string_literal: true

require 'English'
require 'spec_helper'
require 'yaml'

describe 'set_updated_at trigger' do
  def run(cmd)
    system "RAILS_ENV=test bundle exec #{cmd}"
    expect($CHILD_STATUS.exitstatus).to eq 0
  end

  let(:config) { YAML.load(ERB.new(File.read('config/database.yml')).result, aliases: true) }
  before(:all) do
    run 'rake db:drop db:create db:migrate'
  end

  before { ActiveRecord::Base.establish_connection(config['test']) }
  after { ActiveRecord::Base.remove_connection }

  before do
    conn.execute('TRUNCATE builds CASCADE;')
  end

  let(:conn) { ActiveRecord::Base.connection }

  def e(query)
    conn.execute(query)
  end

  def s(query)
    conn.select_one(query)
  end

  it 'sets unique_number on INSERT' do
    e 'INSERT INTO repositories (id, created_at, updated_at) VALUES(1, now(), now())'
    e "INSERT INTO builds (repository_id, number, created_at, updated_at) VALUES (1, '1', now(), now());"
    result = s 'SELECT unique_number FROM builds'
    expect(result['unique_number']).to eql(1)
  end

  it 'does not set unique_number on INSERT if 0 is given as a value' do
    e 'INSERT INTO repositories (id, created_at, updated_at) VALUES(1, now(), now())'
    e "INSERT INTO builds (repository_id, number, unique_number, created_at, updated_at) VALUES (1, '1', 0, now(), now());"
    result = s 'SELECT unique_number FROM builds'
    expect(result['unique_number']).to eql(0)
  end

  it 'sets unique_number on UPDATE' do
    e 'INSERT INTO repositories (id, created_at, updated_at) VALUES(1, now(), now())'
    e "INSERT INTO builds (repository_id, number, created_at, updated_at) VALUES (1, '1', now(), now());"
    e "UPDATE builds SET number = '2';"
    result = s 'SELECT unique_number FROM builds'
    expect(result['unique_number']).to eql(2)
  end

  it 'does not set unique_number on UPDATE if unique_number is 0' do
    e 'INSERT INTO repositories (id, created_at, updated_at) VALUES(1, now(), now())'
    e "INSERT INTO builds (repository_id, number, unique_number, created_at, updated_at) VALUES (1, '1', 0, now(), now());"
    e "UPDATE builds SET number = '2';"
    result = s 'SELECT unique_number FROM builds'
    expect(result['unique_number']).to eql(0)
  end
end
