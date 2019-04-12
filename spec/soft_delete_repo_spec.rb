require 'spec_helper'
require 'yaml'

describe 'soft delete repo' do
  def run(cmd)
    system "RAILS_ENV=test bundle exec #{cmd} > /dev/null"
    expect($?.exitstatus).to eq 0
  end

  module SoftDeleteRepo
    class Table < Struct.new(:name, :fields)
      def matches_fields?(other)
        (self.fields - other.fields).empty? and (other.fields - self.fields).empty?
      end

      def diff(other)
        missing_here = other.fields - self.fields
        missing_there = self.fields - other.fields

        { missing: missing_here.map { |f| f["column_name"] },
          extra: missing_there.map { |f| f["column_name"] } }
      end
    end
  end

  RSpec::Matchers.define :match_fields do |other_table|
    match do |table|
      table.matches_fields?(other_table)
    end

    failure_message do |table|
      diff = table.diff(other_table)

      message = []

      if !diff[:missing].empty?
        message << "Table #{table.name} misses the following fields that #{other_table.name} includes: #{diff[:missing].join(", ")}"
      end

      if !diff[:extra].empty?
        message << "Table #{table.name} has extra fields in comparison with table #{other_table.name}: #{diff[:extra].join(", ")}"
      end

      message.join(". ")
    end

    description do
    end
  end

  def fetch_table(table_name)
    result = e("select column_name, data_type from information_schema.columns where table_name = '#{table_name}';")
    fields = result.entries
    SoftDeleteRepo::Table.new(table_name, fields)
  end

  let(:config) { YAML.load(ERB.new(File.read('config/database.yml')).result) }
  before(:all) do
    run 'rake db:drop db:create db:migrate'
  end

  before { ActiveRecord::Base.establish_connection(config['test']) }
  after { ActiveRecord::Base.remove_connection }

  before do
    conn.execute('TRUNCATE builds, repositories CASCADE;')
  end

  let(:conn)   { ActiveRecord::Base.connection }

  def e(query)
    conn.execute(query)
  end

  def s(query)
    conn.select_one(query)
  end

  specify 'ensure that soft delete tables have the same fields that the originals' do
    tables = %w(builds branches stages jobs requests commits pull_requests
                crons job_configs build_configs request_configs
                request_payloads ssl_keys tags)

    tables.each do |table_name|
      table = fetch_table(table_name)
      deleted_table = fetch_table("deleted_#{table_name}")

      table.should match_fields(deleted_table)
    end
  end

  specify 'soft deleting a repo moves all of the related data to deleted_* tables' do
    e "INSERT INTO repositories (id, created_at, updated_at) VALUES(1, now(), now())"
    e "INSERT INTO commits (id, repository_id, created_at, updated_at) VALUES (1, 1, now(), now());"
    e "INSERT INTO requests (id, repository_id, commit_id, created_at, updated_at) VALUES (1, 1, 1, now(), now());"
    e "INSERT INTO builds (id, repository_id, number, created_at, updated_at) VALUES (1, 1, '1', now(), now());"
    e "INSERT INTO stages (id, build_id) VALUES (1, 1);"
    e "INSERT INTO jobs (source_id, repository_id, number, stage_id, created_at, updated_at) VALUES (1, 1, '1.1', 1, now(), now());"
    e "INSERT INTO jobs (source_id, repository_id, number, stage_id, created_at, updated_at) VALUES (1, 1, '1.2', 1, now(), now());"
    e "INSERT INTO branches (id, repository_id, last_build_id, name, created_at, updated_at)
         VALUES (1, 1, 1, 'master', now(), now());"
    e "INSERT INTO crons (id, branch_id, interval, created_at, updated_at) VALUES (1, 1, '', now(), now());"
    e "INSERT INTO tags (id, repository_id, name, created_at, updated_at) VALUES (1, 1, 'foo', now(), now());"

    result = e "SELECT
      (SELECT count(*) FROM repositories) as repositories_count,
      (SELECT count(*) FROM commits) as commits_count,
      (SELECT count(*) FROM requests) as requests_count,
      (SELECT count(*) FROM builds) as builds_count,
      (SELECT count(*) FROM stages) as stages_count,
      (SELECT count(*) FROM jobs) as jobs_count,
      (SELECT count(*) FROM branches) as branches_count,
      (SELECT count(*) FROM crons) as crons_count,
      (SELECT count(*) FROM tags) as tags_count;
    "

    counts = result.entries.first

    counts["repositories_count"].should == 1
    counts["commits_count"].should == 1
    counts["requests_count"].should == 1
    counts["builds_count"].should == 1
    counts["stages_count"].should == 1
    counts["jobs_count"].should == 2
    counts["branches_count"].should == 1
    counts["crons_count"].should == 1
    counts["tags_count"].should == 1

    e "SELECT soft_delete_repo_data(1);"

    result = e "SELECT
      (SELECT count(*) FROM repositories) as repositories_count,
      (SELECT count(*) FROM commits) as commits_count,
      (SELECT count(*) FROM requests) as requests_count,
      (SELECT count(*) FROM builds) as builds_count,
      (SELECT count(*) FROM stages) as stages_count,
      (SELECT count(*) FROM jobs) as jobs_count,
      (SELECT count(*) FROM branches) as branches_count,
      (SELECT count(*) FROM crons) as crons_count,
      (SELECT count(*) FROM tags) as tags_count;
    "

    counts = result.entries.first

    counts["repositories_count"].should == 1
    counts["commits_count"].should == 0
    counts["requests_count"].should == 0
    counts["builds_count"].should == 0
    counts["stages_count"].should == 0
    counts["jobs_count"].should == 0
    counts["branches_count"].should == 0
    counts["crons_count"].should == 0
    counts["tags_count"].should == 0

    result = e "SELECT
      (SELECT count(*) FROM deleted_commits) as commits_count,
      (SELECT count(*) FROM deleted_requests) as requests_count,
      (SELECT count(*) FROM deleted_builds) as builds_count,
      (SELECT count(*) FROM deleted_stages) as stages_count,
      (SELECT count(*) FROM deleted_jobs) as jobs_count,
      (SELECT count(*) FROM deleted_branches) as branches_count,
      (SELECT count(*) FROM deleted_crons) as crons_count,
      (SELECT count(*) FROM deleted_tags) as tags_count;
    "

    counts = result.entries.first

    counts["commits_count"].should == 1
    counts["requests_count"].should == 1
    counts["builds_count"].should == 1
    counts["stages_count"].should == 1
    counts["jobs_count"].should == 2
    counts["branches_count"].should == 1
    counts["crons_count"].should == 1
    counts["tags_count"].should == 1

  end
end
