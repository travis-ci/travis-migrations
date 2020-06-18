create or replace function agg_all_repo_counts()
returns boolean as $$
begin
  with src as (
    select cnt.repository_id
    from repo_counts cnt
    group by cnt.repository_id
    having count(1) > 1
  ),
  del as (
    delete from repo_counts cnt
    using src
    where cnt.repository_id = src.repository_id
    returning cnt.*
  ),
  agg as (
    select
      del.repository_id,
      sum(del.requests)::integer as requests,
      sum(del.commits)::integer as commits,
      sum(del.branches)::integer as branches,
      sum(del.pull_requests)::integer as pull_requests,
      sum(del.tags)::integer as tags,
      sum(del.builds)::integer as builds,
      -- sum(del.stages)::integer as stages,
      sum(del.jobs)::integer as jobs
    from del
    group by del.repository_id
  )
  insert into repo_counts(
    repository_id,
    requests,
    commits,
    branches,
    pull_requests,
    tags,
    builds,
    -- stages,
    jobs
  )
  select
    agg.repository_id,
    agg.requests,
    agg.commits,
    agg.branches,
    agg.pull_requests,
    agg.tags,
    agg.builds,
    -- agg.stages,
    agg.jobs
  from agg;

  return true;
end;
$$
language plpgsql;

create or replace function agg_repo_counts(_repo_id int)
returns boolean as $$
begin
  with src as (
    select cnt.repository_id
    from repo_counts cnt
    where cnt.repository_id = _repo_id
    group by cnt.repository_id
    having count(1) > 1
  ),
  del as (
    delete from repo_counts cnt
    using src
    where cnt.repository_id = src.repository_id
    returning cnt.*
  ),
  agg as (
    select
      del.repository_id,
      sum(del.requests)::integer as requests,
      sum(del.commits)::integer as commits,
      sum(del.branches)::integer as branches,
      sum(del.pull_requests)::integer as pull_requests,
      sum(del.tags)::integer as tags,
      sum(del.builds)::integer as builds,
      -- sum(del.stages)::integer as stages,
      sum(del.jobs)::integer as jobs
    from del
    group by del.repository_id
  )
  insert into repo_counts(
    repository_id,
    requests,
    commits,
    branches,
    pull_requests,
    tags,
    builds,
    -- stages,
    jobs
  )
  select
    agg.repository_id,
    agg.requests,
    agg.commits,
    agg.branches,
    agg.pull_requests,
    agg.tags,
    agg.builds,
    -- agg.stages,
    agg.jobs
  from agg
  where agg.requests > 0 or agg.builds > 0 or agg.jobs > 0;

  return true;
end;
$$
language plpgsql;