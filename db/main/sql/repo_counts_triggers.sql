create or replace function count_requests() returns trigger as $$
declare
  c text;
  r record;
begin
  if tg_argv[0]::int > 0 then r := new; else r := old; end if;
  if r.repository_id is not null then
    insert into repo_counts(repository_id, requests)
    values(r.repository_id, tg_argv[0]::int);
  end if;
  return r;
exception when others then
  get stacked diagnostics c = pg_exception_context;
  raise warning '% context: %s', sqlerrm, c;
  return r;
end;
$$
language plpgsql;
drop trigger if exists trg_count_request_inserted on requests;
create trigger trg_count_request_inserted after insert on requests
for each row when (now() > '2018-03-27 13:30:00') execute procedure count_requests(1);
drop trigger if exists trg_count_request_deleted on requests;
create trigger trg_count_request_deleted after delete on requests
for each row when (now() > '2018-03-27 13:30:00') execute procedure count_requests('-1');

create or replace function count_commits() returns trigger as $$
declare
  c text;
  r record;
begin
  if tg_argv[0]::int > 0 then r := new; else r := old; end if;
  if r.repository_id is not null then
    insert into repo_counts(repository_id, commits)
    values(r.repository_id, tg_argv[0]::int);
  end if;
  return r;
exception when others then
  get stacked diagnostics c = pg_exception_context;
  raise warning '% context: %s', sqlerrm, c;
  return r;
end;
$$
language plpgsql;
drop trigger if exists trg_count_commit_inserted on commits;
create trigger trg_count_commit_inserted after insert on commits
for each row when (now() > '2018-03-27 13:30:00') execute procedure count_commits(1);
drop trigger if exists trg_count_commit_deleted on commits;
create trigger trg_count_commit_deleted after delete on commits
for each row when (now() > '2018-03-27 13:30:00') execute procedure count_commits('-1');

create or replace function count_branches() returns trigger as $$
declare
  c text;
  r record;
begin
  if tg_argv[0]::int > 0 then r := new; else r := old; end if;
  if r.repository_id is not null then
    insert into repo_counts(repository_id, branches)
    values(r.repository_id, tg_argv[0]::int);
  end if;
  return r;
exception when others then
  get stacked diagnostics c = pg_exception_context;
  raise warning '% context: %s', sqlerrm, c;
  return r;
end;
$$
language plpgsql;
drop trigger if exists trg_count_branch_inserted on branches;
create trigger trg_count_branch_inserted after insert on branches
for each row when (now() > '2018-03-27 13:30:00') execute procedure count_branches(1);
drop trigger if exists trg_count_branch_deleted on branches;
create trigger trg_count_branch_deleted after delete on branches
for each row when (now() > '2018-03-27 13:30:00') execute procedure count_branches('-1');

create or replace function count_pull_requests() returns trigger as $$
declare
  c text;
  r record;
begin
  if tg_argv[0]::int > 0 then r := new; else r := old; end if;
  if r.repository_id is not null then
    insert into repo_counts(repository_id, pull_requests)
    values(r.repository_id, tg_argv[0]::int);
  end if;
  return r;
exception when others then
  get stacked diagnostics c = pg_exception_context;
  raise warning '% context: %s', sqlerrm, c;
  return r;
end;
$$
language plpgsql;
drop trigger if exists trg_count_pull_request_inserted on pull_requests;
create trigger trg_count_pull_request_inserted after insert on pull_requests
for each row when (now() > '2018-03-27 13:30:00') execute procedure count_pull_requests(1);
drop trigger if exists trg_count_pull_request_deleted on pull_requests;
create trigger trg_count_pull_request_deleted after delete on pull_requests
for each row when (now() > '2018-03-27 13:30:00') execute procedure count_pull_requests('-1');

create or replace function count_tags() returns trigger as $$
declare
  c text;
  r record;
begin
  if tg_argv[0]::int > 0 then r := new; else r := old; end if;
  if r.repository_id is not null is not null then
    insert into repo_counts(repository_id, tags)
    values(r.repository_id, tg_argv[0]::int);
  end if;
  return r;
exception when others then
  get stacked diagnostics c = pg_exception_context;
  raise warning '% context: %s', sqlerrm, c;
  return r;
end;
$$
language plpgsql;
drop trigger if exists trg_count_tag_inserted on tags;
create trigger trg_count_tag_inserted after insert on tags
for each row when (now() > '2018-03-27 13:30:00') execute procedure count_tags(1);
drop trigger if exists trg_count_tag_deleted on tags;
create trigger trg_count_tag_deleted after delete on tags
for each row when (now() > '2018-03-27 13:30:00') execute procedure count_tags('-1');

create or replace function count_builds() returns trigger as $$
declare
  c text;
  r record;
begin
  if tg_argv[0]::int > 0 then r := new; else r := old; end if;
  if r.repository_id is not null then
    insert into repo_counts(repository_id, builds)
    values(r.repository_id, tg_argv[0]::int);
  end if;
  return r;
exception when others then
  get stacked diagnostics c = pg_exception_context;
  raise warning '% context: %s', sqlerrm, c;
  return r;
end;
$$
language plpgsql;
drop trigger if exists trg_count_build_inserted on builds;
create trigger trg_count_build_inserted after insert on builds
for each row when (now() > '2018-03-27 13:30:00') execute procedure count_builds(1);
drop trigger if exists trg_count_build_deleted on builds;
create trigger trg_count_build_deleted after delete on builds
for each row when (now() > '2018-03-27 13:30:00') execute procedure count_builds('-1');

-- -- todo stages really should have a repository_id
-- create or replace function count_stages() returns trigger as $$
-- declare
--   c text;
--   r record;
--   build record;
-- begin
--   if tg_argv[0]::int > 0 then r := new; else r := old; end if;
--   select repository_id from builds as b where b.id = r.build_id into build;
--   if build.repository_id is not null then
--     insert into repo_counts(repository_id, stages)
--     values(build.repository_id, tg_argv[0]::int);
--   end if;
--   return r;
-- exception when others then
--   get stacked diagnostics c = pg_exception_context;
--   raise warning '% context: %s', sqlerrm, c;
--   return r;
-- end;
-- $$
-- language plpgsql;
-- drop trigger if exists trg_count_stage_inserted on stages;
-- create trigger trg_count_stage_inserted after insert on stages
-- for each row when (now() > '2018-03-27 13:30:00') execute procedure count_stages(1);
-- drop trigger if exists trg_count_stage_deleted on stages;
-- create trigger trg_count_stage_deleted after delete on stages
-- for each row when (now() > '2018-03-27 13:30:00') execute procedure count_stages('-1');

create or replace function count_jobs() returns trigger as $$
declare
  c text;
  r record;
begin
  if tg_argv[0]::int > 0 then r := new; else r := old; end if;
  if r.repository_id is not null then
    insert into repo_counts(repository_id, jobs)
    values(r.repository_id, tg_argv[0]::int);
  end if;
  return r;
exception when others then
  get stacked diagnostics c = pg_exception_context;
  raise warning '% context: %s', sqlerrm, c;
  return r;
end;
$$
language plpgsql;
drop trigger if exists trg_count_job_inserted on jobs;
create trigger trg_count_job_inserted after insert on jobs
for each row when (now() > '2018-03-27 13:30:00') execute procedure count_jobs(1);
drop trigger if exists trg_count_job_deleted on jobs;
create trigger trg_count_job_deleted after delete on jobs
for each row when (now() > '2018-03-27 13:30:00') execute procedure count_jobs('-1');
