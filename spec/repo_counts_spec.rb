# frozen_string_literal: true

require 'English'
require 'spec_helper'
require 'yaml'

RSpec::Matchers.define :have_counts do |expected|
  match do |actual|
    actual.values_at(*expected.keys) == expected.values
  end
end

describe 'Repo counts' do
  let(:config) { YAML.load(ERB.new(File.read('config/database.yml')).result, aliases: true) }

  before(:all) { run 'rake db:drop db:create db:migrate' }
  before { ActiveRecord::Base.establish_connection(config['test']) }
  after { ActiveRecord::Base.remove_connection }

  def run(cmd)
    system "RAILS_ENV=test bundle exec #{cmd} > migration.log "
    expect($CHILD_STATUS.exitstatus).to eq 0
  end

  def execute(sql)
    ActiveRecord::Base.connection.execute(sql)
  end

  def select_rows(sql)
    ActiveRecord::Base.connection.select_all(sql).map do |row|
      row.map do |key, value|
        [key.to_sym, value.nil? || !value.is_a?(Integer) ? value.to_i : value]
      end.to_h
    end
  end

  def delete_all
    %w[requests commits pull_requests tags stages jobs builds branches].each do |table|
      execute "delete from #{table};"
    end
  end

  before do
    execute %(
      truncate builds cascade;
      truncate repositories cascade;
      truncate repo_counts cascade;
      truncate requests cascade;
      truncate commits cascade;
      truncate branches cascade;
      truncate pull_requests cascade;
      truncate tags cascade;
      truncate stages cascade;
      truncate jobs cascade;

      alter sequence repositories_id_seq restart with 1;
      alter sequence requests_id_seq restart with 1;
      alter sequence commits_id_seq restart with 1;
      alter sequence branches_id_seq restart with 1;
      alter sequence pull_requests_id_seq restart with 1;
      alter sequence tags_id_seq restart with 1;
      alter sequence builds_id_seq restart with 1;
      alter sequence stages_id_seq restart with 1;
      alter sequence jobs_id_seq restart with 1;
      alter sequence shared_builds_tasks_seq restart with 1; -- wat, we're still using this?

      insert into repositories(created_at, updated_at) values
      (now(), now()),
      (now(), now()),
      (now(), now()),
      (now(), now());

      insert into requests(repository_id, created_at, updated_at) values
      (1, now(), now()),
      (1, now(), now()),
      (2, now(), now()),
      (2, now(), now()),
      (3, now(), now()),
      (3, now(), now()),
      (4, now(), now()),
      (4, now(), now());

      insert into commits(repository_id, created_at, updated_at) values
      (1, now(), now()),
      (1, now(), now()),
      (2, now(), now()),
      (2, now(), now()),
      (3, now(), now()),
      (3, now(), now()),
      (4, now(), now()),
      (4, now(), now());

      insert into branches(repository_id, name, created_at, updated_at) values
      (1, 'branch', now(), now()),
      (2, 'branch', now(), now()),
      (4, 'branch', now(), now());

      insert into pull_requests(repository_id, created_at, updated_at) values
      (1, now(), now()),
      (2, now(), now());

      insert into tags(repository_id, created_at, updated_at) values
      (3, now(), now()),
      (3, now(), now());

      insert into builds(repository_id, created_at, updated_at) values
      (1, now(), now()),
      (1, now(), now()),
      (2, now(), now()),
      (2, now(), now()),
      (3, now(), now()),
      (3, now(), now());

      insert into stages(build_id) values
      (1),
      (1);

      insert into jobs(repository_id, created_at, updated_at) values
      (1, now(), now()),
      (1, now(), now()),
      (1, now(), now()),
      (1, now(), now()),
      (1, now(), now()),
      (1, now(), now()),
      (2, now(), now()),
      (2, now(), now()),
      (3, now(), now()),
      (3, now(), now());
    )
  end

  def select_counts(repo_id)
    select_rows(%(
      select
        repository_id,
        requests,
        commits,
        branches,
        pull_requests,
        tags,
        builds,
        stages,
        jobs
      from repo_counts
      where repository_id = #{repo_id}
    )).first
  end

  def select_sums(repo_id)
    select_rows(%(
      select
        repository_id,
        sum(requests) as requests,
        sum(commits) as commits,
        sum(branches) as branches,
        sum(pull_requests) as pull_requests,
        sum(tags) as tags,
        sum(builds) as builds,
        sum(stages) as stages,
        sum(jobs) as jobs
      from repo_counts
      where repository_id = #{repo_id}
      group by repository_id
    )).first
  end

  it 'before aggregation' do
    expect(select_sums(1)).to have_counts(
      requests: 2,
      commits: 2,
      branches: 1,
      pull_requests: 1,
      tags: 0,
      builds: 2,
      stages: 0,
      jobs: 6
    )

    expect(select_sums(2)).to have_counts(
      requests: 2,
      commits: 2,
      branches: 1,
      pull_requests: 1,
      tags: 0,
      builds: 2,
      stages: 0,
      jobs: 2
    )

    expect(select_sums(3)).to have_counts(
      requests: 2,
      commits: 2,
      branches: 0,
      pull_requests: 0,
      tags: 2,
      builds: 2,
      stages: 0,
      jobs: 2
    )

    delete_all

    1.upto(3).each do |id|
      expect(select_sums(id)).to have_counts(
        requests: 0,
        commits: 0,
        branches: 0,
        pull_requests: 0,
        tags: 0,
        builds: 0,
        stages: 0,
        jobs: 0
      )
    end
  end

  it 'after aggregating per repo' do
    1.upto(3) do |id|
      2.times { execute %(select agg_repo_counts(#{id})) }
    end

    expect(select_counts(1)).to have_counts(
      requests: 2,
      commits: 2,
      branches: 1,
      pull_requests: 1,
      tags: 0,
      builds: 2,
      stages: 0,
      jobs: 6
    )

    expect(select_counts(2)).to have_counts(
      requests: 2,
      commits: 2,
      branches: 1,
      pull_requests: 1,
      tags: 0,
      builds: 2,
      stages: 0,
      jobs: 2
    )

    expect(select_counts(3)).to have_counts(
      requests: 2,
      commits: 2,
      branches: 0,
      pull_requests: 0,
      tags: 2,
      builds: 2,
      stages: 0,
      jobs: 2
    )

    delete_all

    1.upto(3).each do |id|
      expect(select_sums(id)).to have_counts(
        requests: 0,
        commits: 0,
        branches: 0,
        pull_requests: 0,
        tags: 0,
        builds: 0,
        stages: 0,
        jobs: 0
      )
    end
  end

  it 'after aggregating all counts' do
    2.times { execute %(select agg_all_repo_counts()) }

    expect(select_counts(1)).to have_counts(
      requests: 2,
      commits: 2,
      branches: 1,
      pull_requests: 1,
      tags: 0,
      builds: 2,
      stages: 0,
      jobs: 6
    )

    expect(select_counts(2)).to have_counts(
      requests: 2,
      commits: 2,
      branches: 1,
      pull_requests: 1,
      tags: 0,
      builds: 2,
      stages: 0,
      jobs: 2
    )

    expect(select_counts(3)).to have_counts(
      requests: 2,
      commits: 2,
      branches: 0,
      pull_requests: 0,
      tags: 2,
      builds: 2,
      stages: 0,
      jobs: 2
    )

    delete_all

    1.upto(3).each do |id|
      expect(select_sums(id)).to have_counts(
        requests: 0,
        commits: 0,
        branches: 0,
        pull_requests: 0,
        tags: 0,
        builds: 0,
        stages: 0,
        jobs: 0
      )
    end
  end

  it 'does not raise if repos are missing' do
    execute %(
      truncate repositories cascade;
      insert into requests(repository_id, created_at, updated_at)
      values (1, now(), now());
    )
  end

  it 'does not raise if builds are deleted before stages' do
    execute %(
      delete from stages;
      delete from builds;
    )
  end
end
