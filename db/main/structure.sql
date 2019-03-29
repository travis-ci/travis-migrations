SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET search_path = public, pg_catalog;

--
-- Name: source_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE source_type AS ENUM (
    'manual',
    'stripe',
    'github',
    'unknown'
);


--
-- Name: agg_all_repo_counts(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION agg_all_repo_counts() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: agg_repo_counts(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION agg_repo_counts(_repo_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: count_all_branches(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_all_branches(_count integer, _start integer, _end integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare max int;
begin
  select id + _count from branches order by id desc limit 1 into max;

  for i in _start.._end by _count loop
    if i > max then exit; end if;
    begin
      raise notice 'counting branches %', i;
      insert into repo_counts(repository_id, branches, range)
      select * from count_branches(i, i + _count - 1);
    exception when unique_violation then end;
  end loop;

  return true;
end
$$;


--
-- Name: count_all_builds(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_all_builds(_count integer, _start integer, _end integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare max int;
begin
  select id + _count from builds order by id desc limit 1 into max;

  for i in _start.._end by _count loop
    if i > max then exit; end if;
    begin
      raise notice 'counting builds %', i;
      insert into repo_counts(repository_id, builds, range)
      select * from count_builds(i, i + _count - 1);
    exception when unique_violation then end;
  end loop;

  return true;
end
$$;


--
-- Name: count_all_commits(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_all_commits(_count integer, _start integer, _end integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare max int;
begin
  select id + _count from commits order by id desc limit 1 into max;

  for i in _start.._end by _count loop
    if i > max then exit; end if;
    begin
      raise notice 'counting commits %', i;
      insert into repo_counts(repository_id, commits, range)
      select * from count_commits(i, i + _count - 1);
    exception when unique_violation then end;
  end loop;

  return true;
end
$$;


--
-- Name: count_all_jobs(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_all_jobs(_count integer, _start integer, _end integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare max int;
begin
  select id + _count from jobs order by id desc limit 1 into max;

  for i in _start.._end by _count loop
    if i > max then exit; end if;
    begin
      raise notice 'counting jobs %', i;
      insert into repo_counts(repository_id, jobs, range)
      select * from count_jobs(i, i + _count - 1);
    exception when unique_violation then end;
  end loop;

  return true;
end
$$;


--
-- Name: count_all_pull_requests(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_all_pull_requests(_count integer, _start integer, _end integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare max int;
begin
  select id + _count from pull_requests order by id desc limit 1 into max;

  for i in _start.._end by _count loop
    if i > max then exit; end if;
    begin
      raise notice 'counting pull_requests %', i;
      insert into repo_counts(repository_id, pull_requests, range)
      select * from count_pull_requests(i, i + _count - 1);
    exception when unique_violation then end;
  end loop;

  return true;
end
$$;


--
-- Name: count_all_requests(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_all_requests(_count integer, _start integer, _end integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare max int;
begin
  select id + _count from requests order by id desc limit 1 into max;
  for i in _start.._end by _count loop
    if i > max then exit; end if;
    begin
      raise notice 'counting requests %', i;
      insert into repo_counts(repository_id, requests, range)
      select * from count_requests(i, i + _count - 1);
    exception when unique_violation then end;
  end loop;

  return true;
end
$$;


--
-- Name: count_all_tags(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_all_tags(_count integer, _start integer, _end integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare max int;
begin
  select id + _count from tags order by id desc limit 1 into max;

  for i in _start.._end by _count loop
    if i > max then exit; end if;
    begin
      raise notice 'counting tags %', i;
      insert into repo_counts(repository_id, tags, range)
      select * from count_tags(i, i + _count - 1);
    exception when unique_violation then end;
  end loop;

  return true;
end
$$;


--
-- Name: count_branches(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_branches() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: count_branches(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_branches(_start integer, _end integer) RETURNS TABLE(repository_id integer, branches bigint, range character varying)
    LANGUAGE plpgsql
    AS $$
begin
  return query select r.id, count(t.id) as branches, ('branches' || ':' || _start || ':' || _end)::varchar as range
  from branches as t
  join repositories as r on t.repository_id = r.id
  where t.id between _start and _end and t.created_at <= '2018-01-01 00:00:00' and t.repository_id is not null
  group by r.id;
end;
$$;


--
-- Name: count_builds(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_builds() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: count_builds(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_builds(_start integer, _end integer) RETURNS TABLE(repository_id integer, builds bigint, range character varying)
    LANGUAGE plpgsql
    AS $$
begin
  return query select t.repository_id, count(id) as builds, ('builds' || ':' || _start || ':' || _end)::varchar as range
  from builds as t
  where t.id between _start and _end and t.created_at <= '2018-01-01 00:00:00' and t.repository_id is not null
  group by t.repository_id;
end;
$$;


--
-- Name: count_commits(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_commits() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: count_commits(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_commits(_start integer, _end integer) RETURNS TABLE(repository_id integer, commits bigint, range character varying)
    LANGUAGE plpgsql
    AS $$
begin
  return query select r.id, count(t.id) as commits, ('commits' || ':' || _start || ':' || _end)::varchar as range
  from commits as t
  join repositories as r on t.repository_id = r.id
  where t.id between _start and _end and t.created_at <= '2018-01-01 00:00:00' and t.repository_id is not null
  group by r.id;
end;
$$;


--
-- Name: count_jobs(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_jobs() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: count_jobs(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_jobs(_start integer, _end integer) RETURNS TABLE(repository_id integer, jobs bigint, range character varying)
    LANGUAGE plpgsql
    AS $$
begin
  return query select t.repository_id, count(id) as jobs, ('jobs' || ':' || _start || ':' || _end)::varchar as range
  from jobs as t
  where t.id between _start and _end and t.created_at <= '2018-01-01 00:00:00' and t.repository_id is not null
  group by t.repository_id;
end;
$$;


--
-- Name: count_pull_requests(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_pull_requests() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: count_pull_requests(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_pull_requests(_start integer, _end integer) RETURNS TABLE(repository_id integer, pull_requests bigint, range character varying)
    LANGUAGE plpgsql
    AS $$
begin
  return query select r.id, count(t.id) as pull_requests, ('pull_requests' || ':' || _start || ':' || _end)::varchar as range
  from pull_requests as t
  join repositories as r on t.repository_id = r.id
  where t.id between _start and _end and t.created_at <= '2018-01-01 00:00:00' and t.repository_id is not null
  group by r.id;
end;
$$;


--
-- Name: count_requests(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_requests() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: count_requests(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_requests(_start integer, _end integer) RETURNS TABLE(repository_id integer, requests bigint, range character varying)
    LANGUAGE plpgsql
    AS $$
begin
  return query select t.repository_id, count(id) as requests, ('requests' || ':' || _start || ':' || _end)::varchar as range
  from requests as t
  where t.id between _start and _end and t.created_at <= '2018-01-01 00:00:00' and t.repository_id is not null
  group by t.repository_id;
end;
$$;


--
-- Name: count_tags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_tags() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: count_tags(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION count_tags(_start integer, _end integer) RETURNS TABLE(repository_id integer, tags bigint, range character varying)
    LANGUAGE plpgsql
    AS $$
begin
  return query select r.id, count(t.id) as tags, ('tags' || ':' || _start || ':' || _end)::varchar as range
  from tags as t
  join repositories as r on t.repository_id = r.id
  where t.id between _start and _end and t.created_at <= '2018-01-01 00:00:00' and t.repository_id is not null
  group by r.id;
end;
$$;


--
-- Name: is_json(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION is_json(text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
  BEGIN
    perform $1::json;
    return true;
  EXCEPTION WHEN invalid_text_representation THEN
    return false;
  END
$_$;


--
-- Name: set_unique_name(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION set_unique_name() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  disable boolean;
BEGIN
  disable := 'f';
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    BEGIN
       disable := current_setting('set_unique_name_on_branches.disable');
    EXCEPTION
    WHEN others THEN
      set set_unique_name_on_branches.disable = 'f';
    END;

    IF NOT disable THEN
      NEW.unique_name := NEW.name;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF TG_OP = 'INSERT' OR
             (TG_OP = 'UPDATE' AND NEW.* IS DISTINCT FROM OLD.*) THEN
          NEW.updated_at := statement_timestamp();
        END IF;
        RETURN NEW;
      END;
      $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: abuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE abuses (
    id integer NOT NULL,
    owner_type character varying,
    owner_id integer,
    request_id integer,
    level integer NOT NULL,
    reason character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: abuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE abuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: abuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE abuses_id_seq OWNED BY abuses.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: beta_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE beta_features (
    id integer NOT NULL,
    name character varying,
    description text,
    feedback_url character varying,
    staff_only boolean,
    default_enabled boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: beta_features_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE beta_features_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: beta_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE beta_features_id_seq OWNED BY beta_features.id;


--
-- Name: beta_migration_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE beta_migration_requests (
    id integer NOT NULL,
    owner_id integer,
    owner_name character varying,
    owner_type character varying,
    created_at timestamp without time zone,
    accepted_at timestamp without time zone
);


--
-- Name: beta_migration_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE beta_migration_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: beta_migration_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE beta_migration_requests_id_seq OWNED BY beta_migration_requests.id;


--
-- Name: branches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE branches (
    id integer NOT NULL,
    repository_id integer NOT NULL,
    last_build_id integer,
    name character varying NOT NULL,
    exists_on_github boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    org_id integer,
    com_id integer,
    unique_name text
);


--
-- Name: branches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE branches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE branches_id_seq OWNED BY branches.id;


--
-- Name: broadcasts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE broadcasts (
    id integer NOT NULL,
    recipient_type character varying,
    recipient_id integer,
    kind character varying,
    message character varying,
    expired boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category character varying
);


--
-- Name: broadcasts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE broadcasts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: broadcasts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE broadcasts_id_seq OWNED BY broadcasts.id;


--
-- Name: build_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE build_configs (
    id integer NOT NULL,
    repository_id integer NOT NULL,
    key character varying NOT NULL,
    config jsonb
);


--
-- Name: build_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE build_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: build_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE build_configs_id_seq OWNED BY build_configs.id;


--
-- Name: shared_builds_tasks_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE shared_builds_tasks_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: builds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE builds (
    id bigint DEFAULT nextval('shared_builds_tasks_seq'::regclass) NOT NULL,
    repository_id integer,
    number character varying,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    log text DEFAULT ''::text,
    message text,
    committed_at timestamp without time zone,
    committer_name character varying,
    committer_email character varying,
    author_name character varying,
    author_email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ref character varying,
    branch character varying,
    github_payload text,
    compare_url character varying,
    token character varying,
    commit_id integer,
    request_id integer,
    state character varying,
    duration integer,
    owner_type character varying,
    owner_id integer,
    event_type character varying,
    previous_state character varying,
    pull_request_title text,
    pull_request_number integer,
    canceled_at timestamp without time zone,
    cached_matrix_ids integer[],
    received_at timestamp without time zone,
    private boolean,
    pull_request_id integer,
    branch_id integer,
    tag_id integer,
    sender_type character varying,
    sender_id integer,
    org_id integer,
    com_id integer,
    config_id integer,
    restarted_at timestamp without time zone
);


--
-- Name: builds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE builds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: builds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE builds_id_seq OWNED BY builds.id;


--
-- Name: cancellations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cancellations (
    id integer NOT NULL,
    subscription_id integer NOT NULL,
    user_id integer,
    plan character varying NOT NULL,
    subscription_start_date date NOT NULL,
    cancellation_date date NOT NULL,
    reason character varying,
    reason_details text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: cancellations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cancellations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cancellations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cancellations_id_seq OWNED BY cancellations.id;


--
-- Name: commits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE commits (
    id integer NOT NULL,
    repository_id integer,
    commit character varying,
    ref character varying,
    branch character varying,
    message text,
    compare_url character varying,
    committed_at timestamp without time zone,
    committer_name character varying,
    committer_email character varying,
    author_name character varying,
    author_email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    branch_id integer,
    tag_id integer,
    org_id integer,
    com_id integer
);


--
-- Name: commits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE commits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE commits_id_seq OWNED BY commits.id;


--
-- Name: coupons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE coupons (
    id integer NOT NULL,
    percent_off integer,
    coupon_id character varying,
    redeem_by timestamp without time zone,
    amount_off integer,
    duration character varying,
    duration_in_months integer,
    max_redemptions integer,
    redemptions integer
);


--
-- Name: coupons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE coupons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: coupons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE coupons_id_seq OWNED BY coupons.id;


--
-- Name: crons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE crons (
    id integer NOT NULL,
    branch_id integer,
    "interval" character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    next_run timestamp without time zone,
    last_run timestamp without time zone,
    dont_run_if_recent_build_exists boolean DEFAULT false,
    org_id integer,
    com_id integer,
    active boolean DEFAULT true
);


--
-- Name: crons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE crons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE crons_id_seq OWNED BY crons.id;


--
-- Name: email_unsubscribes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE email_unsubscribes (
    id bigint NOT NULL,
    user_id integer,
    repository_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: email_unsubscribes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE email_unsubscribes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_unsubscribes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE email_unsubscribes_id_seq OWNED BY email_unsubscribes.id;


--
-- Name: emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE emails (
    id integer NOT NULL,
    user_id integer,
    email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE emails_id_seq OWNED BY emails.id;


--
-- Name: gatekeeper_workers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE gatekeeper_workers (
    id bigint NOT NULL
);


--
-- Name: gatekeeper_workers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gatekeeper_workers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gatekeeper_workers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gatekeeper_workers_id_seq OWNED BY gatekeeper_workers.id;


--
-- Name: installations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE installations (
    id integer NOT NULL,
    github_id integer,
    permissions jsonb,
    owner_type character varying,
    owner_id integer,
    added_by_id integer,
    removed_by_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    removed_at timestamp without time zone
);


--
-- Name: installations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE installations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: installations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE installations_id_seq OWNED BY installations.id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE invoices (
    id integer NOT NULL,
    object text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    subscription_id integer,
    invoice_id character varying,
    stripe_id character varying,
    cc_last_digits character varying
);


--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE invoices_id_seq OWNED BY invoices.id;


--
-- Name: job_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_configs (
    id integer NOT NULL,
    repository_id integer NOT NULL,
    key character varying NOT NULL,
    config jsonb
);


--
-- Name: job_configs_gpu; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW job_configs_gpu AS
 SELECT job_configs.id
   FROM job_configs
  WHERE (is_json((job_configs.config ->> 'resources'::text)) AND ((((job_configs.config ->> 'resources'::text))::jsonb ->> 'gpu'::text) IS NOT NULL))
  WITH NO DATA;


--
-- Name: job_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_configs_id_seq OWNED BY job_configs.id;


--
-- Name: job_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_versions (
    id integer NOT NULL,
    job_id integer,
    number integer,
    state character varying,
    created_at timestamp without time zone,
    queued_at timestamp without time zone,
    received_at timestamp without time zone,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    restarted_at timestamp without time zone
);


--
-- Name: job_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_versions_id_seq OWNED BY job_versions.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE jobs (
    id bigint DEFAULT nextval('shared_builds_tasks_seq'::regclass) NOT NULL,
    repository_id integer,
    commit_id integer,
    source_type character varying,
    source_id integer,
    queue character varying,
    type character varying,
    state character varying,
    number character varying,
    log text DEFAULT ''::text,
    worker character varying,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tags text,
    allow_failure boolean DEFAULT false,
    owner_type character varying,
    owner_id integer,
    result integer,
    queued_at timestamp without time zone,
    canceled_at timestamp without time zone,
    received_at timestamp without time zone,
    debug_options text,
    private boolean,
    stage_number character varying,
    stage_id integer,
    org_id integer,
    com_id integer,
    config_id integer,
    restarted_at timestamp without time zone
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE jobs_id_seq OWNED BY jobs.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE memberships (
    id integer NOT NULL,
    organization_id integer,
    user_id integer,
    role character varying
);


--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE memberships_id_seq OWNED BY memberships.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE messages (
    id integer NOT NULL,
    subject_id integer,
    subject_type character varying,
    level character varying,
    key character varying,
    code character varying,
    args json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE messages_id_seq OWNED BY messages.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE organizations (
    id integer NOT NULL,
    name character varying,
    login character varying,
    github_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    avatar_url character varying,
    location character varying,
    email character varying,
    company character varying,
    homepage character varying,
    billing_admin_only boolean,
    org_id integer,
    com_id integer,
    migrating boolean,
    migrated_at timestamp without time zone,
    preferences jsonb DEFAULT '{}'::jsonb,
    beta_migration_request_id integer
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organizations_id_seq OWNED BY organizations.id;


--
-- Name: owner_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE owner_groups (
    id integer NOT NULL,
    uuid character varying,
    owner_type character varying,
    owner_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: owner_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE owner_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: owner_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE owner_groups_id_seq OWNED BY owner_groups.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE permissions (
    id integer NOT NULL,
    user_id integer,
    repository_id integer,
    admin boolean DEFAULT false,
    push boolean DEFAULT false,
    pull boolean DEFAULT false,
    org_id integer,
    com_id integer
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE permissions_id_seq OWNED BY permissions.id;


--
-- Name: pull_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pull_requests (
    id integer NOT NULL,
    repository_id integer,
    number integer,
    title character varying,
    state character varying,
    head_repo_github_id integer,
    head_repo_slug character varying,
    head_ref character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    org_id integer,
    com_id integer
);


--
-- Name: pull_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pull_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pull_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pull_requests_id_seq OWNED BY pull_requests.id;


--
-- Name: queueable_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE queueable_jobs (
    id integer NOT NULL,
    job_id integer
);


--
-- Name: queueable_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE queueable_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: queueable_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE queueable_jobs_id_seq OWNED BY queueable_jobs.id;


--
-- Name: repo_counts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE repo_counts (
    repository_id integer NOT NULL,
    requests integer,
    commits integer,
    branches integer,
    pull_requests integer,
    tags integer,
    builds integer,
    stages integer,
    jobs integer,
    range character varying
);


--
-- Name: repositories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE repositories (
    id integer NOT NULL,
    name character varying,
    url character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_build_id integer,
    last_build_number character varying,
    last_build_started_at timestamp without time zone,
    last_build_finished_at timestamp without time zone,
    owner_name character varying,
    owner_email text,
    active boolean,
    description text,
    last_build_duration integer,
    owner_type character varying,
    owner_id integer,
    private boolean DEFAULT false,
    last_build_state character varying,
    github_id integer,
    default_branch character varying,
    github_language character varying,
    settings json,
    next_build_number integer,
    invalidated_at timestamp without time zone,
    current_build_id bigint,
    org_id integer,
    com_id integer,
    migrating boolean,
    migrated_at timestamp without time zone,
    active_on_org boolean,
    managed_by_installation_at timestamp without time zone,
    migration_status character varying
);


--
-- Name: repositories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repositories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE repositories_id_seq OWNED BY repositories.id;


--
-- Name: request_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE request_configs (
    id integer NOT NULL,
    repository_id integer NOT NULL,
    key character varying NOT NULL,
    config jsonb
);


--
-- Name: request_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE request_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: request_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE request_configs_id_seq OWNED BY request_configs.id;


--
-- Name: request_payloads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE request_payloads (
    id integer NOT NULL,
    request_id integer NOT NULL,
    payload text,
    archived boolean DEFAULT false,
    created_at timestamp without time zone
);


--
-- Name: request_payloads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE request_payloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: request_payloads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE request_payloads_id_seq OWNED BY request_payloads.id;


--
-- Name: request_raw_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE request_raw_configs (
    id integer NOT NULL,
    config text,
    repository_id integer,
    key character varying NOT NULL
);


--
-- Name: request_raw_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE request_raw_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: request_raw_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE request_raw_configs_id_seq OWNED BY request_raw_configs.id;


--
-- Name: request_raw_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE request_raw_configurations (
    id integer NOT NULL,
    request_id integer,
    request_raw_config_id integer,
    source character varying
);


--
-- Name: request_raw_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE request_raw_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: request_raw_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE request_raw_configurations_id_seq OWNED BY request_raw_configurations.id;


--
-- Name: request_yaml_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE request_yaml_configs (
    id integer NOT NULL,
    yaml text,
    repository_id integer,
    key character varying NOT NULL
);


--
-- Name: request_yaml_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE request_yaml_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: request_yaml_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE request_yaml_configs_id_seq OWNED BY request_yaml_configs.id;


--
-- Name: requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE requests (
    id integer NOT NULL,
    repository_id integer,
    commit_id integer,
    state character varying,
    source character varying,
    token character varying,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    event_type character varying,
    comments_url character varying,
    base_commit character varying,
    head_commit character varying,
    owner_type character varying,
    owner_id integer,
    result character varying,
    message character varying,
    private boolean,
    pull_request_id integer,
    branch_id integer,
    tag_id integer,
    sender_type character varying,
    sender_id integer,
    org_id integer,
    com_id integer,
    config_id integer,
    yaml_config_id integer,
    github_guid text
);


--
-- Name: requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE requests_id_seq OWNED BY requests.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: ssl_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ssl_keys (
    id integer NOT NULL,
    repository_id integer,
    public_key text,
    private_key text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    org_id integer,
    com_id integer
);


--
-- Name: ssl_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ssl_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ssl_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ssl_keys_id_seq OWNED BY ssl_keys.id;


--
-- Name: stages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE stages (
    id integer NOT NULL,
    build_id integer,
    number integer,
    name character varying,
    state character varying,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    org_id integer,
    com_id integer
);


--
-- Name: stages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stages_id_seq OWNED BY stages.id;


--
-- Name: stars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE stars (
    id integer NOT NULL,
    repository_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stars_id_seq OWNED BY stars.id;


--
-- Name: stripe_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE stripe_events (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    event_object text,
    event_type character varying,
    date timestamp without time zone,
    event_id character varying
);


--
-- Name: stripe_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stripe_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stripe_events_id_seq OWNED BY stripe_events.id;


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE subscriptions (
    id integer NOT NULL,
    cc_token character varying,
    valid_to timestamp without time zone,
    owner_type character varying NOT NULL,
    owner_id integer NOT NULL,
    first_name character varying,
    last_name character varying,
    company character varying,
    zip_code character varying,
    address character varying,
    address2 character varying,
    city character varying,
    state character varying,
    country character varying,
    vat_id character varying,
    customer_id character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    cc_owner character varying,
    cc_last_digits character varying,
    cc_expiration_date character varying,
    billing_email character varying,
    selected_plan character varying,
    coupon character varying,
    contact_id integer,
    canceled_at timestamp without time zone,
    canceled_by_id integer,
    status character varying,
    source source_type DEFAULT 'unknown'::source_type NOT NULL,
    concurrency integer
);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subscriptions_id_seq OWNED BY subscriptions.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tags (
    id integer NOT NULL,
    repository_id integer,
    name character varying,
    last_build_id integer,
    exists_on_github boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    org_id integer,
    com_id integer
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tokens (
    id integer NOT NULL,
    user_id integer,
    token character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tokens_id_seq OWNED BY tokens.id;


--
-- Name: trial_allowances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE trial_allowances (
    id integer NOT NULL,
    trial_id integer,
    creator_id integer,
    creator_type character varying,
    builds_allowed integer,
    builds_remaining integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: trial_allowances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trial_allowances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trial_allowances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trial_allowances_id_seq OWNED BY trial_allowances.id;


--
-- Name: trials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE trials (
    id integer NOT NULL,
    owner_type character varying,
    owner_id integer,
    chartmogul_customer_uuids text[] DEFAULT '{}'::text[],
    status character varying DEFAULT 'new'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trials_id_seq OWNED BY trials.id;


--
-- Name: urls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE urls (
    id integer NOT NULL,
    url character varying,
    code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: urls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE urls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE urls_id_seq OWNED BY urls.id;


--
-- Name: user_beta_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_beta_features (
    id integer NOT NULL,
    user_id integer,
    beta_feature_id integer,
    enabled boolean,
    last_deactivated_at timestamp without time zone,
    last_activated_at timestamp without time zone
);


--
-- Name: user_beta_features_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_beta_features_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_beta_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_beta_features_id_seq OWNED BY user_beta_features.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    name character varying,
    login character varying,
    email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_admin boolean DEFAULT false,
    github_id integer,
    github_oauth_token character varying,
    gravatar_id character varying,
    locale character varying,
    is_syncing boolean,
    synced_at timestamp without time zone,
    github_scopes text,
    education boolean,
    first_logged_in_at timestamp without time zone,
    avatar_url character varying,
    suspended boolean DEFAULT false,
    suspended_at timestamp without time zone,
    org_id integer,
    com_id integer,
    migrating boolean,
    migrated_at timestamp without time zone,
    redacted_at timestamp without time zone,
    preferences jsonb DEFAULT '{}'::jsonb
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: abuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY abuses ALTER COLUMN id SET DEFAULT nextval('abuses_id_seq'::regclass);


--
-- Name: beta_features id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY beta_features ALTER COLUMN id SET DEFAULT nextval('beta_features_id_seq'::regclass);


--
-- Name: beta_migration_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY beta_migration_requests ALTER COLUMN id SET DEFAULT nextval('beta_migration_requests_id_seq'::regclass);


--
-- Name: branches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY branches ALTER COLUMN id SET DEFAULT nextval('branches_id_seq'::regclass);


--
-- Name: broadcasts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY broadcasts ALTER COLUMN id SET DEFAULT nextval('broadcasts_id_seq'::regclass);


--
-- Name: build_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY build_configs ALTER COLUMN id SET DEFAULT nextval('build_configs_id_seq'::regclass);


--
-- Name: cancellations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cancellations ALTER COLUMN id SET DEFAULT nextval('cancellations_id_seq'::regclass);


--
-- Name: commits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY commits ALTER COLUMN id SET DEFAULT nextval('commits_id_seq'::regclass);


--
-- Name: coupons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY coupons ALTER COLUMN id SET DEFAULT nextval('coupons_id_seq'::regclass);


--
-- Name: crons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY crons ALTER COLUMN id SET DEFAULT nextval('crons_id_seq'::regclass);


--
-- Name: email_unsubscribes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_unsubscribes ALTER COLUMN id SET DEFAULT nextval('email_unsubscribes_id_seq'::regclass);


--
-- Name: emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY emails ALTER COLUMN id SET DEFAULT nextval('emails_id_seq'::regclass);


--
-- Name: gatekeeper_workers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY gatekeeper_workers ALTER COLUMN id SET DEFAULT nextval('gatekeeper_workers_id_seq'::regclass);


--
-- Name: installations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY installations ALTER COLUMN id SET DEFAULT nextval('installations_id_seq'::regclass);


--
-- Name: invoices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY invoices ALTER COLUMN id SET DEFAULT nextval('invoices_id_seq'::regclass);


--
-- Name: job_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_configs ALTER COLUMN id SET DEFAULT nextval('job_configs_id_seq'::regclass);


--
-- Name: job_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_versions ALTER COLUMN id SET DEFAULT nextval('job_versions_id_seq'::regclass);


--
-- Name: memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY memberships ALTER COLUMN id SET DEFAULT nextval('memberships_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages ALTER COLUMN id SET DEFAULT nextval('messages_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations ALTER COLUMN id SET DEFAULT nextval('organizations_id_seq'::regclass);


--
-- Name: owner_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY owner_groups ALTER COLUMN id SET DEFAULT nextval('owner_groups_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions ALTER COLUMN id SET DEFAULT nextval('permissions_id_seq'::regclass);


--
-- Name: pull_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pull_requests ALTER COLUMN id SET DEFAULT nextval('pull_requests_id_seq'::regclass);


--
-- Name: queueable_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY queueable_jobs ALTER COLUMN id SET DEFAULT nextval('queueable_jobs_id_seq'::regclass);


--
-- Name: repositories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY repositories ALTER COLUMN id SET DEFAULT nextval('repositories_id_seq'::regclass);


--
-- Name: request_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_configs ALTER COLUMN id SET DEFAULT nextval('request_configs_id_seq'::regclass);


--
-- Name: request_payloads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_payloads ALTER COLUMN id SET DEFAULT nextval('request_payloads_id_seq'::regclass);


--
-- Name: request_raw_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_raw_configs ALTER COLUMN id SET DEFAULT nextval('request_raw_configs_id_seq'::regclass);


--
-- Name: request_raw_configurations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_raw_configurations ALTER COLUMN id SET DEFAULT nextval('request_raw_configurations_id_seq'::regclass);


--
-- Name: request_yaml_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_yaml_configs ALTER COLUMN id SET DEFAULT nextval('request_yaml_configs_id_seq'::regclass);


--
-- Name: requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY requests ALTER COLUMN id SET DEFAULT nextval('requests_id_seq'::regclass);


--
-- Name: ssl_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ssl_keys ALTER COLUMN id SET DEFAULT nextval('ssl_keys_id_seq'::regclass);


--
-- Name: stages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stages ALTER COLUMN id SET DEFAULT nextval('stages_id_seq'::regclass);


--
-- Name: stars id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stars ALTER COLUMN id SET DEFAULT nextval('stars_id_seq'::regclass);


--
-- Name: stripe_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_events ALTER COLUMN id SET DEFAULT nextval('stripe_events_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subscriptions ALTER COLUMN id SET DEFAULT nextval('subscriptions_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tokens ALTER COLUMN id SET DEFAULT nextval('tokens_id_seq'::regclass);


--
-- Name: trial_allowances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trial_allowances ALTER COLUMN id SET DEFAULT nextval('trial_allowances_id_seq'::regclass);


--
-- Name: trials id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trials ALTER COLUMN id SET DEFAULT nextval('trials_id_seq'::regclass);


--
-- Name: urls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY urls ALTER COLUMN id SET DEFAULT nextval('urls_id_seq'::regclass);


--
-- Name: user_beta_features id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_beta_features ALTER COLUMN id SET DEFAULT nextval('user_beta_features_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: abuses abuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY abuses
    ADD CONSTRAINT abuses_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: beta_features beta_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY beta_features
    ADD CONSTRAINT beta_features_pkey PRIMARY KEY (id);


--
-- Name: beta_migration_requests beta_migration_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY beta_migration_requests
    ADD CONSTRAINT beta_migration_requests_pkey PRIMARY KEY (id);


--
-- Name: branches branches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (id);


--
-- Name: broadcasts broadcasts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY broadcasts
    ADD CONSTRAINT broadcasts_pkey PRIMARY KEY (id);


--
-- Name: build_configs build_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY build_configs
    ADD CONSTRAINT build_configs_pkey PRIMARY KEY (id);


--
-- Name: builds builds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY builds
    ADD CONSTRAINT builds_pkey PRIMARY KEY (id);


--
-- Name: cancellations cancellations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cancellations
    ADD CONSTRAINT cancellations_pkey PRIMARY KEY (id);


--
-- Name: commits commits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY commits
    ADD CONSTRAINT commits_pkey PRIMARY KEY (id);


--
-- Name: coupons coupons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY coupons
    ADD CONSTRAINT coupons_pkey PRIMARY KEY (id);


--
-- Name: crons crons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY crons
    ADD CONSTRAINT crons_pkey PRIMARY KEY (id);


--
-- Name: email_unsubscribes email_unsubscribes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_unsubscribes
    ADD CONSTRAINT email_unsubscribes_pkey PRIMARY KEY (id);


--
-- Name: emails emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: gatekeeper_workers gatekeeper_workers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gatekeeper_workers
    ADD CONSTRAINT gatekeeper_workers_pkey PRIMARY KEY (id);


--
-- Name: installations installations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY installations
    ADD CONSTRAINT installations_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: job_configs job_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_configs
    ADD CONSTRAINT job_configs_pkey PRIMARY KEY (id);


--
-- Name: job_versions job_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_versions
    ADD CONSTRAINT job_versions_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: owner_groups owner_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY owner_groups
    ADD CONSTRAINT owner_groups_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: pull_requests pull_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pull_requests
    ADD CONSTRAINT pull_requests_pkey PRIMARY KEY (id);


--
-- Name: queueable_jobs queueable_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY queueable_jobs
    ADD CONSTRAINT queueable_jobs_pkey PRIMARY KEY (id);


--
-- Name: repositories repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY repositories
    ADD CONSTRAINT repositories_pkey PRIMARY KEY (id);


--
-- Name: request_configs request_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_configs
    ADD CONSTRAINT request_configs_pkey PRIMARY KEY (id);


--
-- Name: request_payloads request_payloads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_payloads
    ADD CONSTRAINT request_payloads_pkey PRIMARY KEY (id);


--
-- Name: request_raw_configs request_raw_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_raw_configs
    ADD CONSTRAINT request_raw_configs_pkey PRIMARY KEY (id);


--
-- Name: request_raw_configurations request_raw_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_raw_configurations
    ADD CONSTRAINT request_raw_configurations_pkey PRIMARY KEY (id);


--
-- Name: request_yaml_configs request_yaml_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_yaml_configs
    ADD CONSTRAINT request_yaml_configs_pkey PRIMARY KEY (id);


--
-- Name: requests requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY requests
    ADD CONSTRAINT requests_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: ssl_keys ssl_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ssl_keys
    ADD CONSTRAINT ssl_keys_pkey PRIMARY KEY (id);


--
-- Name: stages stages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stages
    ADD CONSTRAINT stages_pkey PRIMARY KEY (id);


--
-- Name: stars stars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stars
    ADD CONSTRAINT stars_pkey PRIMARY KEY (id);


--
-- Name: stripe_events stripe_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stripe_events
    ADD CONSTRAINT stripe_events_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- Name: trial_allowances trial_allowances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trial_allowances
    ADD CONSTRAINT trial_allowances_pkey PRIMARY KEY (id);


--
-- Name: trials trials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trials
    ADD CONSTRAINT trials_pkey PRIMARY KEY (id);


--
-- Name: urls urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY urls
    ADD CONSTRAINT urls_pkey PRIMARY KEY (id);


--
-- Name: user_beta_features user_beta_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_beta_features
    ADD CONSTRAINT user_beta_features_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: github_id_installations_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX github_id_installations_idx ON installations USING btree (github_id);


--
-- Name: index_abuses_on_owner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_abuses_on_owner ON abuses USING btree (owner_id);


--
-- Name: index_abuses_on_owner_id_and_owner_type_and_level; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_abuses_on_owner_id_and_owner_type_and_level ON abuses USING btree (owner_id, owner_type, level);


--
-- Name: index_active_on_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_on_org ON repositories USING btree (active_on_org);


--
-- Name: index_beta_migration_requests_on_owner_type_and_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_beta_migration_requests_on_owner_type_and_owner_id ON beta_migration_requests USING btree (owner_type, owner_id);


--
-- Name: index_branches_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_branches_on_com_id ON branches USING btree (com_id);


--
-- Name: index_branches_on_last_build_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_branches_on_last_build_id ON branches USING btree (last_build_id);


--
-- Name: index_branches_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_branches_on_org_id ON branches USING btree (org_id);


--
-- Name: index_branches_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_branches_on_repository_id ON branches USING btree (repository_id);


--
-- Name: index_branches_on_repository_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_branches_on_repository_id_and_name ON branches USING btree (repository_id, name);


--
-- Name: index_branches_on_repository_id_and_name_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_branches_on_repository_id_and_name_and_id ON branches USING btree (repository_id, name, id);


--
-- Name: index_branches_repository_id_unique_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_branches_repository_id_unique_name ON branches USING btree (repository_id, unique_name) WHERE (unique_name IS NOT NULL);


--
-- Name: index_broadcasts_on_recipient_id_and_recipient_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_broadcasts_on_recipient_id_and_recipient_type ON broadcasts USING btree (recipient_id, recipient_type);


--
-- Name: index_build_configs_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_build_configs_on_repository_id ON build_configs USING btree (repository_id);


--
-- Name: index_build_configs_on_repository_id_and_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_build_configs_on_repository_id_and_key ON build_configs USING btree (repository_id, key);


--
-- Name: index_builds_on_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_branch_id ON builds USING btree (branch_id);


--
-- Name: index_builds_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_builds_on_com_id ON builds USING btree (com_id);


--
-- Name: index_builds_on_commit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_commit_id ON builds USING btree (commit_id);


--
-- Name: index_builds_on_config_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_config_id ON builds USING btree (config_id);


--
-- Name: index_builds_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_created_at ON builds USING btree (created_at);


--
-- Name: index_builds_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_builds_on_org_id ON builds USING btree (org_id);


--
-- Name: index_builds_on_pull_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_pull_request_id ON builds USING btree (pull_request_id);


--
-- Name: index_builds_on_repo_branch_event_type_and_private; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_repo_branch_event_type_and_private ON builds USING btree (repository_id, branch, event_type, private);


--
-- Name: index_builds_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_repository_id ON builds USING btree (repository_id);


--
-- Name: index_builds_on_repository_id_and_branch_and_event_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_repository_id_and_branch_and_event_type ON builds USING btree (repository_id, branch, event_type) WHERE ((state)::text = ANY ((ARRAY['created'::character varying, 'queued'::character varying, 'received'::character varying])::text[]));


--
-- Name: index_builds_on_repository_id_and_branch_and_event_type_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_repository_id_and_branch_and_event_type_and_id ON builds USING btree (repository_id, branch, event_type, id);


--
-- Name: index_builds_on_repository_id_and_branch_and_id_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_repository_id_and_branch_and_id_desc ON builds USING btree (repository_id, branch, id DESC);


--
-- Name: index_builds_on_repository_id_and_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_repository_id_and_number ON builds USING btree (repository_id, ((number)::integer));


--
-- Name: index_builds_on_repository_id_and_number_and_event_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_repository_id_and_number_and_event_type ON builds USING btree (repository_id, number, event_type);


--
-- Name: index_builds_on_repository_id_event_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_repository_id_event_type_id ON builds USING btree (repository_id, event_type, id DESC);


--
-- Name: index_builds_on_repository_id_where_state_not_finished; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_repository_id_where_state_not_finished ON builds USING btree (repository_id) WHERE ((state)::text = ANY ((ARRAY['created'::character varying, 'queued'::character varying, 'received'::character varying, 'started'::character varying])::text[]));


--
-- Name: index_builds_on_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_request_id ON builds USING btree (request_id);


--
-- Name: index_builds_on_sender_type_and_sender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_sender_type_and_sender_id ON builds USING btree (sender_type, sender_id);


--
-- Name: index_builds_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_state ON builds USING btree (state);


--
-- Name: index_builds_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_tag_id ON builds USING btree (tag_id);


--
-- Name: index_builds_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_updated_at ON builds USING btree (updated_at);


--
-- Name: index_cancellations_on_subscription_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cancellations_on_subscription_id ON cancellations USING btree (subscription_id);


--
-- Name: index_commits_on_author_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commits_on_author_email ON commits USING btree (author_email);


--
-- Name: index_commits_on_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commits_on_branch_id ON commits USING btree (branch_id);


--
-- Name: index_commits_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_commits_on_com_id ON commits USING btree (com_id);


--
-- Name: index_commits_on_committer_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commits_on_committer_email ON commits USING btree (committer_email);


--
-- Name: index_commits_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_commits_on_org_id ON commits USING btree (org_id);


--
-- Name: index_commits_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commits_on_repository_id ON commits USING btree (repository_id);


--
-- Name: index_commits_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commits_on_tag_id ON commits USING btree (tag_id);


--
-- Name: index_crons_on_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_crons_on_branch_id ON crons USING btree (branch_id);


--
-- Name: index_crons_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_crons_on_com_id ON crons USING btree (com_id);


--
-- Name: index_crons_on_next_run; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_crons_on_next_run ON crons USING btree (next_run) WHERE (active IS TRUE);


--
-- Name: index_crons_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_crons_on_org_id ON crons USING btree (org_id);


--
-- Name: index_email_unsubscribes_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_unsubscribes_on_repository_id ON email_unsubscribes USING btree (repository_id);


--
-- Name: index_email_unsubscribes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_unsubscribes_on_user_id ON email_unsubscribes USING btree (user_id);


--
-- Name: index_email_unsubscribes_on_user_id_and_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_email_unsubscribes_on_user_id_and_repository_id ON email_unsubscribes USING btree (user_id, repository_id);


--
-- Name: index_emails_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_email ON emails USING btree (email);


--
-- Name: index_emails_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_user_id ON emails USING btree (user_id);


--
-- Name: index_installations_on_owner_type_and_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_installations_on_owner_type_and_owner_id ON installations USING btree (owner_type, owner_id);


--
-- Name: index_invoices_on_stripe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invoices_on_stripe_id ON invoices USING btree (stripe_id);


--
-- Name: index_job_configs_on_config_resources_gpu; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_configs_on_config_resources_gpu ON job_configs USING btree (((((config ->> 'resources'::text))::jsonb ->> 'gpu'::text))) WHERE (is_json((config ->> 'resources'::text)) AND ((((config ->> 'resources'::text))::jsonb ->> 'gpu'::text) IS NOT NULL));


--
-- Name: index_job_configs_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_configs_on_repository_id ON job_configs USING btree (repository_id);


--
-- Name: index_job_configs_on_repository_id_and_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_configs_on_repository_id_and_key ON job_configs USING btree (repository_id, key);


--
-- Name: index_jobs_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_jobs_on_com_id ON jobs USING btree (com_id);


--
-- Name: index_jobs_on_commit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_commit_id ON jobs USING btree (commit_id);


--
-- Name: index_jobs_on_config_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_config_id ON jobs USING btree (config_id);


--
-- Name: index_jobs_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_created_at ON jobs USING btree (created_at);


--
-- Name: index_jobs_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_jobs_on_org_id ON jobs USING btree (org_id);


--
-- Name: index_jobs_on_owner_id_and_owner_type_and_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_owner_id_and_owner_type_and_state ON jobs USING btree (owner_id, owner_type, state);


--
-- Name: index_jobs_on_owner_where_state_running; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_owner_where_state_running ON jobs USING btree (owner_id, owner_type) WHERE ((state)::text = ANY ((ARRAY['queued'::character varying, 'received'::character varying, 'started'::character varying])::text[]));


--
-- Name: index_jobs_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_repository_id ON jobs USING btree (repository_id);


--
-- Name: index_jobs_on_repository_id_where_state_running; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_repository_id_where_state_running ON jobs USING btree (repository_id) WHERE ((state)::text = ANY ((ARRAY['queued'::character varying, 'received'::character varying, 'started'::character varying])::text[]));


--
-- Name: index_jobs_on_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_source_id ON jobs USING btree (source_id);


--
-- Name: index_jobs_on_stage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_stage_id ON jobs USING btree (stage_id);


--
-- Name: index_jobs_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_state ON jobs USING btree (state);


--
-- Name: index_jobs_on_type_and_source_id_and_source_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_type_and_source_id_and_source_type ON jobs USING btree (type, source_id, source_type);


--
-- Name: index_jobs_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_updated_at ON jobs USING btree (updated_at);


--
-- Name: index_memberships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_user_id ON memberships USING btree (user_id);


--
-- Name: index_messages_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_messages_on_subject_type_and_subject_id ON messages USING btree (subject_type, subject_id);


--
-- Name: index_organization_id_and_user_id_on_memberships; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organization_id_and_user_id_on_memberships ON memberships USING btree (organization_id, user_id);


--
-- Name: index_organizations_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_com_id ON organizations USING btree (com_id);


--
-- Name: index_organizations_on_github_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_github_id ON organizations USING btree (github_id);


--
-- Name: index_organizations_on_login; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_login ON organizations USING btree (login);


--
-- Name: index_organizations_on_lower_login; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_lower_login ON organizations USING btree (lower((login)::text));


--
-- Name: index_organizations_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_org_id ON organizations USING btree (org_id);


--
-- Name: index_organizations_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_updated_at ON organizations USING btree (updated_at);


--
-- Name: index_owner_groups_on_owner_type_and_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_owner_groups_on_owner_type_and_owner_id ON owner_groups USING btree (owner_type, owner_id);


--
-- Name: index_owner_groups_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_owner_groups_on_uuid ON owner_groups USING btree (uuid);


--
-- Name: index_permissions_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permissions_on_com_id ON permissions USING btree (com_id);


--
-- Name: index_permissions_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permissions_on_org_id ON permissions USING btree (org_id);


--
-- Name: index_permissions_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_on_repository_id ON permissions USING btree (repository_id);


--
-- Name: index_permissions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_on_user_id ON permissions USING btree (user_id);


--
-- Name: index_permissions_on_user_id_and_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permissions_on_user_id_and_repository_id ON permissions USING btree (user_id, repository_id);


--
-- Name: index_pull_requests_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pull_requests_on_com_id ON pull_requests USING btree (com_id);


--
-- Name: index_pull_requests_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pull_requests_on_org_id ON pull_requests USING btree (org_id);


--
-- Name: index_pull_requests_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pull_requests_on_repository_id ON pull_requests USING btree (repository_id);


--
-- Name: index_pull_requests_on_repository_id_and_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pull_requests_on_repository_id_and_number ON pull_requests USING btree (repository_id, number);


--
-- Name: index_queueable_jobs_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_queueable_jobs_on_job_id ON queueable_jobs USING btree (job_id);


--
-- Name: index_repo_counts_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repo_counts_on_repository_id ON repo_counts USING btree (repository_id);


--
-- Name: index_repositories_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_active ON repositories USING btree (active);


--
-- Name: index_repositories_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_repositories_on_com_id ON repositories USING btree (com_id);


--
-- Name: index_repositories_on_current_build_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_current_build_id ON repositories USING btree (current_build_id);


--
-- Name: index_repositories_on_github_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_repositories_on_github_id ON repositories USING btree (github_id);


--
-- Name: index_repositories_on_last_build_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_last_build_id ON repositories USING btree (last_build_id);


--
-- Name: index_repositories_on_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_lower_name ON repositories USING btree (lower((name)::text));


--
-- Name: index_repositories_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_name ON repositories USING btree (name);


--
-- Name: index_repositories_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_repositories_on_org_id ON repositories USING btree (org_id);


--
-- Name: index_repositories_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_owner_id ON repositories USING btree (owner_id);


--
-- Name: index_repositories_on_owner_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_owner_name ON repositories USING btree (owner_name);


--
-- Name: index_repositories_on_owner_name_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_owner_name_and_name ON repositories USING btree (owner_name, name) WHERE (invalidated_at IS NULL);


--
-- Name: index_repositories_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_slug ON repositories USING gin (((((owner_name)::text || '/'::text) || (name)::text)) gin_trgm_ops);


--
-- Name: index_repositories_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_updated_at ON repositories USING btree (updated_at);


--
-- Name: index_request_configs_on_repository_id_and_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_request_configs_on_repository_id_and_key ON request_configs USING btree (repository_id, key);


--
-- Name: index_request_payloads_on_created_at_and_archived; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_request_payloads_on_created_at_and_archived ON request_payloads USING btree (created_at, archived);


--
-- Name: index_request_payloads_on_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_request_payloads_on_request_id ON request_payloads USING btree (request_id);


--
-- Name: index_request_raw_configs_on_repository_id_and_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_request_raw_configs_on_repository_id_and_key ON request_raw_configs USING btree (repository_id, key);


--
-- Name: index_request_raw_configurations_on_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_request_raw_configurations_on_request_id ON request_raw_configurations USING btree (request_id);


--
-- Name: index_request_raw_configurations_on_request_raw_config_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_request_raw_configurations_on_request_raw_config_id ON request_raw_configurations USING btree (request_raw_config_id);


--
-- Name: index_request_yaml_configs_on_repository_id_and_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_request_yaml_configs_on_repository_id_and_key ON request_yaml_configs USING btree (repository_id, key);


--
-- Name: index_requests_on_branch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requests_on_branch_id ON requests USING btree (branch_id);


--
-- Name: index_requests_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_requests_on_com_id ON requests USING btree (com_id);


--
-- Name: index_requests_on_commit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requests_on_commit_id ON requests USING btree (commit_id);


--
-- Name: index_requests_on_config_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requests_on_config_id ON requests USING btree (config_id);


--
-- Name: index_requests_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requests_on_created_at ON requests USING btree (created_at);


--
-- Name: index_requests_on_github_guid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_requests_on_github_guid ON requests USING btree (github_guid);


--
-- Name: index_requests_on_head_commit; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requests_on_head_commit ON requests USING btree (head_commit);


--
-- Name: index_requests_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_requests_on_org_id ON requests USING btree (org_id);


--
-- Name: index_requests_on_pull_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requests_on_pull_request_id ON requests USING btree (pull_request_id);


--
-- Name: index_requests_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requests_on_repository_id ON requests USING btree (repository_id);


--
-- Name: index_requests_on_repository_id_and_id_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requests_on_repository_id_and_id_desc ON requests USING btree (repository_id, id DESC);


--
-- Name: index_requests_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requests_on_tag_id ON requests USING btree (tag_id);


--
-- Name: index_ssl_key_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ssl_key_on_repository_id ON ssl_keys USING btree (repository_id);


--
-- Name: index_ssl_keys_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ssl_keys_on_com_id ON ssl_keys USING btree (com_id);


--
-- Name: index_ssl_keys_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ssl_keys_on_org_id ON ssl_keys USING btree (org_id);


--
-- Name: index_stages_on_build_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stages_on_build_id ON stages USING btree (build_id);


--
-- Name: index_stages_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stages_on_com_id ON stages USING btree (com_id);


--
-- Name: index_stages_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stages_on_org_id ON stages USING btree (org_id);


--
-- Name: index_stars_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stars_on_user_id ON stars USING btree (user_id);


--
-- Name: index_stars_on_user_id_and_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stars_on_user_id_and_repository_id ON stars USING btree (user_id, repository_id);


--
-- Name: index_stripe_events_on_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_events_on_date ON stripe_events USING btree (date);


--
-- Name: index_stripe_events_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_events_on_event_id ON stripe_events USING btree (event_id);


--
-- Name: index_stripe_events_on_event_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_events_on_event_type ON stripe_events USING btree (event_type);


--
-- Name: index_tags_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_com_id ON tags USING btree (com_id);


--
-- Name: index_tags_on_last_build_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_last_build_id ON tags USING btree (last_build_id);


--
-- Name: index_tags_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_org_id ON tags USING btree (org_id);


--
-- Name: index_tags_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_repository_id ON tags USING btree (repository_id);


--
-- Name: index_tags_on_repository_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_repository_id_and_name ON tags USING btree (repository_id, name);


--
-- Name: index_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tokens_on_token ON tokens USING btree (token);


--
-- Name: index_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tokens_on_user_id ON tokens USING btree (user_id);


--
-- Name: index_trial_allowances_on_creator_id_and_creator_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trial_allowances_on_creator_id_and_creator_type ON trial_allowances USING btree (creator_id, creator_type);


--
-- Name: index_trial_allowances_on_trial_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trial_allowances_on_trial_id ON trial_allowances USING btree (trial_id);


--
-- Name: index_trials_on_owner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trials_on_owner ON trials USING btree (owner_id, owner_type);


--
-- Name: index_user_beta_features_on_user_id_and_beta_feature_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_beta_features_on_user_id_and_beta_feature_id ON user_beta_features USING btree (user_id, beta_feature_id);


--
-- Name: index_users_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_com_id ON users USING btree (com_id);


--
-- Name: index_users_on_github_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_github_id ON users USING btree (github_id);


--
-- Name: index_users_on_github_oauth_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_github_oauth_token ON users USING btree (github_oauth_token);


--
-- Name: index_users_on_login; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_login ON users USING btree (login);


--
-- Name: index_users_on_lower_login; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_lower_login ON users USING btree (lower((login)::text));


--
-- Name: index_users_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_org_id ON users USING btree (org_id);


--
-- Name: index_users_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_updated_at ON users USING btree (updated_at);


--
-- Name: managed_repositories_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX managed_repositories_idx ON repositories USING btree (managed_by_installation_at);


--
-- Name: owner_installations_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX owner_installations_idx ON installations USING btree (owner_id, owner_type) WHERE (removed_by_id IS NULL);


--
-- Name: subscriptions_owner; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX subscriptions_owner ON subscriptions USING btree (owner_id, owner_type) WHERE ((status)::text = 'subscribed'::text);


--
-- Name: user_preferences_build_emails_false; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_preferences_build_emails_false ON users USING btree (id) WHERE ((preferences ->> 'build_emails'::text) = 'false'::text);


--
-- Name: branches set_unique_name_on_branches; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_unique_name_on_branches BEFORE INSERT OR UPDATE ON branches FOR EACH ROW EXECUTE PROCEDURE set_unique_name();


--
-- Name: builds set_updated_at_on_builds; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_at_on_builds BEFORE INSERT OR UPDATE ON builds FOR EACH ROW EXECUTE PROCEDURE set_updated_at();


--
-- Name: jobs set_updated_at_on_jobs; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_at_on_jobs BEFORE INSERT OR UPDATE ON jobs FOR EACH ROW EXECUTE PROCEDURE set_updated_at();


--
-- Name: branches trg_count_branch_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_branch_deleted AFTER DELETE ON branches FOR EACH ROW WHEN ((now() > '2018-01-01 00:00:00+00'::timestamp with time zone)) EXECUTE PROCEDURE count_branches('-1');


--
-- Name: branches trg_count_branch_inserted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_branch_inserted AFTER INSERT ON branches FOR EACH ROW WHEN ((now() > '2018-01-01 00:00:00+00'::timestamp with time zone)) EXECUTE PROCEDURE count_branches('1');


--
-- Name: builds trg_count_build_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_build_deleted AFTER DELETE ON builds FOR EACH ROW WHEN ((now() > '2018-01-01 00:00:00+00'::timestamp with time zone)) EXECUTE PROCEDURE count_builds('-1');


--
-- Name: builds trg_count_build_inserted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_build_inserted AFTER INSERT ON builds FOR EACH ROW WHEN ((now() > '2018-01-01 00:00:00+00'::timestamp with time zone)) EXECUTE PROCEDURE count_builds('1');


--
-- Name: commits trg_count_commit_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_commit_deleted AFTER DELETE ON commits FOR EACH ROW WHEN ((now() > '2018-01-01 00:00:00+00'::timestamp with time zone)) EXECUTE PROCEDURE count_commits('-1');


--
-- Name: commits trg_count_commit_inserted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_commit_inserted AFTER INSERT ON commits FOR EACH ROW WHEN ((now() > '2018-01-01 00:00:00+00'::timestamp with time zone)) EXECUTE PROCEDURE count_commits('1');


--
-- Name: jobs trg_count_job_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_job_deleted AFTER DELETE ON jobs FOR EACH ROW WHEN ((now() > '2018-01-01 00:00:00+00'::timestamp with time zone)) EXECUTE PROCEDURE count_jobs('-1');


--
-- Name: jobs trg_count_job_inserted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_job_inserted AFTER INSERT ON jobs FOR EACH ROW WHEN ((now() > '2018-01-01 00:00:00+00'::timestamp with time zone)) EXECUTE PROCEDURE count_jobs('1');


--
-- Name: pull_requests trg_count_pull_request_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_pull_request_deleted AFTER DELETE ON pull_requests FOR EACH ROW WHEN ((now() > '2018-01-01 00:00:00+00'::timestamp with time zone)) EXECUTE PROCEDURE count_pull_requests('-1');


--
-- Name: pull_requests trg_count_pull_request_inserted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_pull_request_inserted AFTER INSERT ON pull_requests FOR EACH ROW WHEN ((now() > '2018-01-01 00:00:00+00'::timestamp with time zone)) EXECUTE PROCEDURE count_pull_requests('1');


--
-- Name: requests trg_count_request_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_request_deleted AFTER DELETE ON requests FOR EACH ROW WHEN ((now() > '2018-01-01 00:00:00+00'::timestamp with time zone)) EXECUTE PROCEDURE count_requests('-1');


--
-- Name: requests trg_count_request_inserted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_request_inserted AFTER INSERT ON requests FOR EACH ROW WHEN ((now() > '2018-01-01 00:00:00+00'::timestamp with time zone)) EXECUTE PROCEDURE count_requests('1');


--
-- Name: tags trg_count_tag_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_tag_deleted AFTER DELETE ON tags FOR EACH ROW WHEN ((now() > '2018-01-01 00:00:00+00'::timestamp with time zone)) EXECUTE PROCEDURE count_tags('-1');


--
-- Name: tags trg_count_tag_inserted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_tag_inserted AFTER INSERT ON tags FOR EACH ROW WHEN ((now() > '2018-01-01 00:00:00+00'::timestamp with time zone)) EXECUTE PROCEDURE count_tags('1');


--
-- Name: branches fk_branches_on_last_build_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY branches
    ADD CONSTRAINT fk_branches_on_last_build_id FOREIGN KEY (last_build_id) REFERENCES builds(id) ON DELETE SET NULL;


--
-- Name: branches fk_branches_on_repository_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY branches
    ADD CONSTRAINT fk_branches_on_repository_id FOREIGN KEY (repository_id) REFERENCES repositories(id);


--
-- Name: build_configs fk_build_configs_on_repository_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY build_configs
    ADD CONSTRAINT fk_build_configs_on_repository_id FOREIGN KEY (repository_id) REFERENCES repositories(id);


--
-- Name: builds fk_builds_on_branch_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY builds
    ADD CONSTRAINT fk_builds_on_branch_id FOREIGN KEY (branch_id) REFERENCES branches(id);


--
-- Name: builds fk_builds_on_commit_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY builds
    ADD CONSTRAINT fk_builds_on_commit_id FOREIGN KEY (commit_id) REFERENCES commits(id);


--
-- Name: builds fk_builds_on_config_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY builds
    ADD CONSTRAINT fk_builds_on_config_id FOREIGN KEY (config_id) REFERENCES build_configs(id);


--
-- Name: builds fk_builds_on_pull_request_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY builds
    ADD CONSTRAINT fk_builds_on_pull_request_id FOREIGN KEY (pull_request_id) REFERENCES pull_requests(id);


--
-- Name: builds fk_builds_on_repository_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY builds
    ADD CONSTRAINT fk_builds_on_repository_id FOREIGN KEY (repository_id) REFERENCES repositories(id);


--
-- Name: builds fk_builds_on_request_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY builds
    ADD CONSTRAINT fk_builds_on_request_id FOREIGN KEY (request_id) REFERENCES requests(id);


--
-- Name: builds fk_builds_on_tag_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY builds
    ADD CONSTRAINT fk_builds_on_tag_id FOREIGN KEY (tag_id) REFERENCES tags(id);


--
-- Name: commits fk_commits_on_branch_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY commits
    ADD CONSTRAINT fk_commits_on_branch_id FOREIGN KEY (branch_id) REFERENCES branches(id);


--
-- Name: commits fk_commits_on_repository_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY commits
    ADD CONSTRAINT fk_commits_on_repository_id FOREIGN KEY (repository_id) REFERENCES repositories(id);


--
-- Name: commits fk_commits_on_tag_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY commits
    ADD CONSTRAINT fk_commits_on_tag_id FOREIGN KEY (tag_id) REFERENCES tags(id);


--
-- Name: crons fk_crons_on_branch_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY crons
    ADD CONSTRAINT fk_crons_on_branch_id FOREIGN KEY (branch_id) REFERENCES branches(id);


--
-- Name: job_configs fk_job_configs_on_repository_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_configs
    ADD CONSTRAINT fk_job_configs_on_repository_id FOREIGN KEY (repository_id) REFERENCES repositories(id);


--
-- Name: jobs fk_jobs_on_commit_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT fk_jobs_on_commit_id FOREIGN KEY (commit_id) REFERENCES commits(id);


--
-- Name: jobs fk_jobs_on_config_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT fk_jobs_on_config_id FOREIGN KEY (config_id) REFERENCES job_configs(id);


--
-- Name: jobs fk_jobs_on_repository_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT fk_jobs_on_repository_id FOREIGN KEY (repository_id) REFERENCES repositories(id);


--
-- Name: jobs fk_jobs_on_stage_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT fk_jobs_on_stage_id FOREIGN KEY (stage_id) REFERENCES stages(id);


--
-- Name: pull_requests fk_pull_requests_on_repository_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pull_requests
    ADD CONSTRAINT fk_pull_requests_on_repository_id FOREIGN KEY (repository_id) REFERENCES repositories(id);


--
-- Name: installations fk_rails_2d567d406d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY installations
    ADD CONSTRAINT fk_rails_2d567d406d FOREIGN KEY (added_by_id) REFERENCES users(id);


--
-- Name: installations fk_rails_75a0a2a3b4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY installations
    ADD CONSTRAINT fk_rails_75a0a2a3b4 FOREIGN KEY (removed_by_id) REFERENCES users(id);


--
-- Name: repositories fk_repositories_on_current_build_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY repositories
    ADD CONSTRAINT fk_repositories_on_current_build_id FOREIGN KEY (current_build_id) REFERENCES builds(id) ON DELETE SET NULL;


--
-- Name: repositories fk_repositories_on_last_build_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY repositories
    ADD CONSTRAINT fk_repositories_on_last_build_id FOREIGN KEY (last_build_id) REFERENCES builds(id) ON DELETE SET NULL;


--
-- Name: requests fk_requests_on_branch_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY requests
    ADD CONSTRAINT fk_requests_on_branch_id FOREIGN KEY (branch_id) REFERENCES branches(id);


--
-- Name: requests fk_requests_on_commit_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY requests
    ADD CONSTRAINT fk_requests_on_commit_id FOREIGN KEY (commit_id) REFERENCES commits(id);


--
-- Name: requests fk_requests_on_config_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY requests
    ADD CONSTRAINT fk_requests_on_config_id FOREIGN KEY (config_id) REFERENCES request_configs(id);


--
-- Name: requests fk_requests_on_pull_request_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY requests
    ADD CONSTRAINT fk_requests_on_pull_request_id FOREIGN KEY (pull_request_id) REFERENCES pull_requests(id);


--
-- Name: requests fk_requests_on_tag_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY requests
    ADD CONSTRAINT fk_requests_on_tag_id FOREIGN KEY (tag_id) REFERENCES tags(id);


--
-- Name: ssl_keys fk_ssl_keys_on_repository_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ssl_keys
    ADD CONSTRAINT fk_ssl_keys_on_repository_id FOREIGN KEY (repository_id) REFERENCES repositories(id);


--
-- Name: stages fk_stages_on_build_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stages
    ADD CONSTRAINT fk_stages_on_build_id FOREIGN KEY (build_id) REFERENCES builds(id);


--
-- Name: tags fk_tags_on_last_build_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT fk_tags_on_last_build_id FOREIGN KEY (last_build_id) REFERENCES builds(id) ON DELETE SET NULL;


--
-- Name: tags fk_tags_on_repository_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT fk_tags_on_repository_id FOREIGN KEY (repository_id) REFERENCES repositories(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20101126174706'),
('20101126174715'),
('20110109130532'),
('20110116155100'),
('20110130102621'),
('20110301071656'),
('20110316174721'),
('20110321075539'),
('20110411171936'),
('20110411171937'),
('20110411172518'),
('20110413101057'),
('20110414131100'),
('20110503150504'),
('20110523012243'),
('20110611203537'),
('20110613210252'),
('20110615152003'),
('20110616211744'),
('20110617114728'),
('20110619100906'),
('20110729094426'),
('20110801161819'),
('20110805030147'),
('20110819232908'),
('20110911204538'),
('20111107134436'),
('20111107134437'),
('20111107134438'),
('20111107134439'),
('20111107134440'),
('20111128235043'),
('20111129014329'),
('20111129022625'),
('20111201113500'),
('20111203002341'),
('20111203221720'),
('20111207093700'),
('20111212103859'),
('20111212112411'),
('20111214173922'),
('20120114125404'),
('20120216133223'),
('20120222082522'),
('20120301131209'),
('20120304000502'),
('20120304000503'),
('20120304000504'),
('20120304000505'),
('20120304000506'),
('20120311234933'),
('20120316123726'),
('20120319170001'),
('20120324104051'),
('20120505165100'),
('20120511171900'),
('20120521174400'),
('20120527235800'),
('20120702111126'),
('20120703114226'),
('20120713140816'),
('20120713153215'),
('20120725005300'),
('201207261749'),
('20120727151900'),
('20120731005301'),
('20120731074000'),
('20120802001001'),
('20120803164000'),
('20120803182300'),
('20120804122700'),
('20120806120400'),
('20120820164000'),
('20120905093300'),
('20120905171300'),
('20120911160000'),
('20120911230000'),
('20120911230001'),
('20120913143800'),
('20120915012000'),
('20120915012001'),
('20120915150000'),
('20121015002500'),
('20121015002501'),
('20121017040100'),
('20121017040200'),
('20121018201301'),
('20121018203728'),
('20121018210156'),
('20121125122700'),
('20121125122701'),
('20121222125200'),
('20121222125300'),
('20121222140200'),
('20121223162300'),
('20130107165057'),
('20130115125836'),
('20130115145728'),
('20130125002600'),
('20130125171100'),
('20130129142703'),
('20130208135800'),
('20130208135801'),
('20130306154311'),
('20130311211101'),
('20130327100801'),
('20130418101437'),
('20130418103306'),
('20130505023259'),
('20130521115725'),
('20130521133050'),
('20130521134224'),
('20130521134800'),
('20130521141357'),
('20130618084205'),
('20130629122945'),
('20130629133531'),
('20130629174449'),
('20130701175200'),
('20130702123456'),
('20130702144325'),
('20130705123456'),
('20130707164854'),
('20130709185200'),
('20130709233500'),
('20130710000745'),
('20130726101124'),
('20130901183019'),
('20130909203321'),
('20130910184823'),
('20130916101056'),
('20130920135744'),
('20131104101056'),
('20131109101056'),
('20140120225125'),
('20140121003026'),
('20140204220926'),
('20140210003014'),
('20140210012509'),
('20140612131826'),
('20140827121945'),
('20150121135400'),
('20150121135401'),
('20150204144312'),
('20150210170900'),
('20150223125700'),
('20150311020321'),
('20150316020321'),
('20150316080321'),
('20150316100321'),
('20150317004600'),
('20150317020321'),
('20150317080321'),
('20150414001337'),
('20150528101600'),
('20150528101601'),
('20150528101602'),
('20150528101603'),
('20150528101604'),
('20150528101605'),
('20150528101607'),
('20150528101608'),
('20150528101609'),
('20150528101610'),
('20150528101611'),
('20150609175200'),
('20150610143500'),
('20150610143501'),
('20150610143502'),
('20150610143503'),
('20150610143504'),
('20150610143505'),
('20150610143506'),
('20150610143507'),
('20150610143508'),
('20150610143509'),
('20150610143510'),
('20150615103059'),
('20150629231300'),
('20150923131400'),
('20151112153500'),
('20151113111400'),
('20151127153500'),
('20151127154200'),
('20151127154600'),
('20151202122200'),
('20160107120927'),
('20160303165750'),
('20160412113020'),
('20160412113070'),
('20160412121405'),
('20160412123900'),
('20160414214442'),
('20160422104300'),
('20160422121400'),
('20160510142700'),
('20160510144200'),
('20160510150300'),
('20160510150400'),
('20160513074300'),
('20160609163600'),
('20160623133900'),
('20160623133901'),
('20160712125400'),
('20160819103700'),
('20160920220400'),
('20161028154600'),
('20161101000000'),
('20161101000001'),
('20161201112200'),
('20161201112600'),
('20161202000000'),
('20161206155800'),
('20161221171300'),
('20170211000000'),
('20170211000001'),
('20170211000002'),
('20170211000003'),
('20170213124000'),
('20170316000000'),
('20170316000001'),
('20170318000000'),
('20170318000001'),
('20170318000002'),
('20170322000000'),
('20170331000000'),
('20170401000000'),
('20170401000001'),
('20170401000002'),
('20170405000000'),
('20170405000001'),
('20170405000002'),
('20170405000003'),
('20170408000000'),
('20170408000001'),
('20170410000000'),
('20170411000000'),
('20170419093249'),
('20170531125700'),
('20170601163700'),
('20170601164400'),
('20170609174400'),
('20170613000000'),
('20170620144500'),
('20170621142300'),
('20170713162000'),
('20170822171600'),
('20170831000000'),
('20170911172800'),
('20171017104500'),
('20171024000000'),
('20171025000000'),
('20171103000000'),
('20171211000000'),
('20180212000000'),
('20180213000000'),
('20180222000000'),
('20180222000001'),
('20180222000002'),
('20180222000003'),
('20180222000009'),
('20180222000012'),
('20180222164100'),
('20180305143800'),
('20180321102400'),
('20180330000000'),
('20180331000000'),
('20180404000001'),
('20180410000000'),
('20180413000000'),
('20180417000000'),
('20180420000000'),
('20180425000000'),
('20180425100000'),
('20180429000000'),
('20180501000000'),
('20180517000000'),
('20180517000001'),
('20180517000002'),
('20180518000000'),
('20180522000000'),
('20180531000000'),
('20180606000000'),
('20180606000001'),
('20180614000000'),
('20180614000001'),
('20180614000002'),
('20180620000000'),
('20180725000000'),
('20180726000000'),
('20180726000001'),
('20180801000001'),
('20180822000000'),
('20180823000000'),
('20180828000000'),
('20180829000000'),
('20180830000001'),
('20180830000002'),
('20180830000003'),
('20180903000000'),
('20180903000001'),
('20180904000001'),
('20180906000000'),
('20181002115306'),
('20181002115307'),
('20181018000000'),
('20181029120000'),
('20181113120000'),
('20181116800000'),
('20181116800001'),
('20181126080000'),
('20181128120000'),
('20181203075818'),
('20181203075819'),
('20181203080356'),
('20181205152712'),
('20190102000000'),
('20190102000001'),
('20190109000000'),
('20190118000000'),
('20190204000000'),
('20190313000000'),
('20190329093854');


