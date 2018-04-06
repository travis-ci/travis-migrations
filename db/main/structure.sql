--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.8
-- Dumped by pg_dump version 9.6.8

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
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


--
-- Name: source_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.source_type AS ENUM (
    'manual',
    'stripe',
    'github',
    'unknown'
);


--
-- Name: agg_all_repo_counts(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.agg_all_repo_counts() RETURNS boolean
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

CREATE FUNCTION public.agg_repo_counts(_repo_id integer) RETURNS boolean
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

CREATE FUNCTION public.count_all_branches(_count integer, _start integer, _end integer) RETURNS boolean
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

CREATE FUNCTION public.count_all_builds(_count integer, _start integer, _end integer) RETURNS boolean
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

CREATE FUNCTION public.count_all_commits(_count integer, _start integer, _end integer) RETURNS boolean
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

CREATE FUNCTION public.count_all_jobs(_count integer, _start integer, _end integer) RETURNS boolean
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

CREATE FUNCTION public.count_all_pull_requests(_count integer, _start integer, _end integer) RETURNS boolean
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

CREATE FUNCTION public.count_all_requests(_count integer, _start integer, _end integer) RETURNS boolean
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

CREATE FUNCTION public.count_all_tags(_count integer, _start integer, _end integer) RETURNS boolean
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

CREATE FUNCTION public.count_branches() RETURNS trigger
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

CREATE FUNCTION public.count_branches(_start integer, _end integer) RETURNS TABLE(repository_id integer, branches bigint, range character varying)
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

CREATE FUNCTION public.count_builds() RETURNS trigger
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

CREATE FUNCTION public.count_builds(_start integer, _end integer) RETURNS TABLE(repository_id integer, builds bigint, range character varying)
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

CREATE FUNCTION public.count_commits() RETURNS trigger
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

CREATE FUNCTION public.count_commits(_start integer, _end integer) RETURNS TABLE(repository_id integer, commits bigint, range character varying)
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

CREATE FUNCTION public.count_jobs() RETURNS trigger
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

CREATE FUNCTION public.count_jobs(_start integer, _end integer) RETURNS TABLE(repository_id integer, jobs bigint, range character varying)
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

CREATE FUNCTION public.count_pull_requests() RETURNS trigger
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

CREATE FUNCTION public.count_pull_requests(_start integer, _end integer) RETURNS TABLE(repository_id integer, pull_requests bigint, range character varying)
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

CREATE FUNCTION public.count_requests() RETURNS trigger
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

CREATE FUNCTION public.count_requests(_start integer, _end integer) RETURNS TABLE(repository_id integer, requests bigint, range character varying)
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

CREATE FUNCTION public.count_tags() RETURNS trigger
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

CREATE FUNCTION public.count_tags(_start integer, _end integer) RETURNS TABLE(repository_id integer, tags bigint, range character varying)
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
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
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

CREATE TABLE public.abuses (
    id integer NOT NULL,
    owner_id integer,
    owner_type character varying,
    request_id integer,
    level integer NOT NULL,
    reason character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: abuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.abuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: abuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.abuses_id_seq OWNED BY public.abuses.id;


--
-- Name: beta_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.beta_features (
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

CREATE SEQUENCE public.beta_features_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: beta_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.beta_features_id_seq OWNED BY public.beta_features.id;


--
-- Name: branches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.branches (
    id integer NOT NULL,
    repository_id integer NOT NULL,
    last_build_id integer,
    name character varying NOT NULL,
    exists_on_github boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    org_id integer,
    com_id integer
);


--
-- Name: branches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.branches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: branches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.branches_id_seq OWNED BY public.branches.id;


--
-- Name: broadcasts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.broadcasts (
    id integer NOT NULL,
    recipient_id integer,
    recipient_type character varying,
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

CREATE SEQUENCE public.broadcasts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: broadcasts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.broadcasts_id_seq OWNED BY public.broadcasts.id;


--
-- Name: build_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.build_configs (
    id integer NOT NULL,
    repository_id integer NOT NULL,
    key character varying NOT NULL,
    config text
);


--
-- Name: build_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.build_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: build_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.build_configs_id_seq OWNED BY public.build_configs.id;


--
-- Name: shared_builds_tasks_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shared_builds_tasks_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: builds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.builds (
    id bigint DEFAULT nextval('public.shared_builds_tasks_seq'::regclass) NOT NULL,
    repository_id integer,
    number character varying,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    config text,
    commit_id integer,
    request_id integer,
    state character varying,
    duration integer,
    owner_id integer,
    owner_type character varying,
    event_type character varying,
    previous_state character varying,
    pull_request_title text,
    pull_request_number integer,
    branch character varying,
    canceled_at timestamp without time zone,
    cached_matrix_ids integer[],
    received_at timestamp without time zone,
    private boolean,
    pull_request_id integer,
    branch_id integer,
    tag_id integer,
    sender_id integer,
    sender_type character varying,
    org_id integer,
    com_id integer,
    config_id integer
);


--
-- Name: builds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.builds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: builds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.builds_id_seq OWNED BY public.builds.id;


--
-- Name: commits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commits (
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

CREATE SEQUENCE public.commits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.commits_id_seq OWNED BY public.commits.id;


--
-- Name: coupons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coupons (
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

CREATE SEQUENCE public.coupons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: coupons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.coupons_id_seq OWNED BY public.coupons.id;


--
-- Name: crons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crons (
    id integer NOT NULL,
    branch_id integer,
    "interval" character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    next_run timestamp without time zone,
    last_run timestamp without time zone,
    dont_run_if_recent_build_exists boolean DEFAULT false,
    org_id integer,
    com_id integer
);


--
-- Name: crons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crons_id_seq OWNED BY public.crons.id;


--
-- Name: emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emails (
    id integer NOT NULL,
    user_id integer,
    email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.emails_id_seq OWNED BY public.emails.id;


--
-- Name: installations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.installations (
    id integer NOT NULL,
    owner_id integer,
    owner_type character varying,
    github_id integer,
    permissions jsonb,
    added_by_id integer,
    removed_by_id integer,
    removed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    added_by_id_id integer,
    removed_by_id_id integer
);


--
-- Name: installations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.installations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: installations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.installations_id_seq OWNED BY public.installations.id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoices (
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

CREATE SEQUENCE public.invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invoices_id_seq OWNED BY public.invoices.id;


--
-- Name: job_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_configs (
    id integer NOT NULL,
    repository_id integer NOT NULL,
    key character varying NOT NULL,
    config text
);


--
-- Name: job_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_configs_id_seq OWNED BY public.job_configs.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id bigint DEFAULT nextval('public.shared_builds_tasks_seq'::regclass) NOT NULL,
    repository_id integer,
    commit_id integer,
    source_id integer,
    source_type character varying,
    queue character varying,
    type character varying,
    state character varying,
    number character varying,
    config text,
    worker character varying,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tags text,
    allow_failure boolean DEFAULT false,
    owner_id integer,
    owner_type character varying,
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
    config_id integer
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.memberships (
    id integer NOT NULL,
    organization_id integer,
    user_id integer,
    role character varying
);


--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.memberships_id_seq OWNED BY public.memberships.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
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

CREATE SEQUENCE public.messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
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
    migrated_at timestamp without time zone
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: owner_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.owner_groups (
    id integer NOT NULL,
    uuid character varying,
    owner_id integer,
    owner_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: owner_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.owner_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: owner_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.owner_groups_id_seq OWNED BY public.owner_groups.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
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

CREATE SEQUENCE public.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: pull_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pull_requests (
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

CREATE SEQUENCE public.pull_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pull_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pull_requests_id_seq OWNED BY public.pull_requests.id;


--
-- Name: queueable_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.queueable_jobs (
    id integer NOT NULL,
    job_id integer
);


--
-- Name: queueable_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.queueable_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: queueable_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.queueable_jobs_id_seq OWNED BY public.queueable_jobs.id;


--
-- Name: repo_counts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repo_counts (
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

CREATE TABLE public.repositories (
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
    owner_id integer,
    owner_type character varying,
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
    managed_by_installation_at timestamp without time zone
);


--
-- Name: repositories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repositories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repositories_id_seq OWNED BY public.repositories.id;


--
-- Name: request_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.request_configs (
    id integer NOT NULL,
    repository_id integer NOT NULL,
    key character varying NOT NULL,
    config text
);


--
-- Name: request_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.request_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: request_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.request_configs_id_seq OWNED BY public.request_configs.id;


--
-- Name: request_payloads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.request_payloads (
    id integer NOT NULL,
    request_id integer NOT NULL,
    payload text,
    archived boolean DEFAULT false,
    created_at timestamp without time zone
);


--
-- Name: request_payloads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.request_payloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: request_payloads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.request_payloads_id_seq OWNED BY public.request_payloads.id;


--
-- Name: requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.requests (
    id integer NOT NULL,
    repository_id integer,
    commit_id integer,
    state character varying,
    source character varying,
    payload text,
    token character varying,
    config text,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    event_type character varying,
    comments_url character varying,
    base_commit character varying,
    head_commit character varying,
    owner_id integer,
    owner_type character varying,
    result character varying,
    message character varying,
    private boolean,
    pull_request_id integer,
    branch_id integer,
    tag_id integer,
    sender_id integer,
    sender_type character varying,
    org_id integer,
    com_id integer,
    config_id integer
);


--
-- Name: requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.requests_id_seq OWNED BY public.requests.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: ssl_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ssl_keys (
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

CREATE SEQUENCE public.ssl_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ssl_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ssl_keys_id_seq OWNED BY public.ssl_keys.id;


--
-- Name: stages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stages (
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

CREATE SEQUENCE public.stages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stages_id_seq OWNED BY public.stages.id;


--
-- Name: stars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stars (
    id integer NOT NULL,
    repository_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stars_id_seq OWNED BY public.stars.id;


--
-- Name: stripe_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_events (
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

CREATE SEQUENCE public.stripe_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stripe_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stripe_events_id_seq OWNED BY public.stripe_events.id;


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id integer NOT NULL,
    cc_token character varying,
    valid_to timestamp without time zone,
    owner_id integer,
    owner_type character varying,
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
    source public.source_type DEFAULT 'unknown'::public.source_type NOT NULL,
    concurrency integer
);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
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

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tokens (
    id integer NOT NULL,
    user_id integer,
    token character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tokens_id_seq OWNED BY public.tokens.id;


--
-- Name: trial_allowances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trial_allowances (
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

CREATE SEQUENCE public.trial_allowances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trial_allowances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trial_allowances_id_seq OWNED BY public.trial_allowances.id;


--
-- Name: trials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trials (
    id integer NOT NULL,
    owner_id integer,
    owner_type character varying,
    chartmogul_customer_uuids text[] DEFAULT '{}'::text[],
    status character varying DEFAULT 'new'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trials_id_seq OWNED BY public.trials.id;


--
-- Name: urls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.urls (
    id integer NOT NULL,
    url character varying,
    code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: urls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.urls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.urls_id_seq OWNED BY public.urls.id;


--
-- Name: user_beta_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_beta_features (
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

CREATE SEQUENCE public.user_beta_features_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_beta_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_beta_features_id_seq OWNED BY public.user_beta_features.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
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
    migrated_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: abuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.abuses ALTER COLUMN id SET DEFAULT nextval('public.abuses_id_seq'::regclass);


--
-- Name: beta_features id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.beta_features ALTER COLUMN id SET DEFAULT nextval('public.beta_features_id_seq'::regclass);


--
-- Name: branches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branches ALTER COLUMN id SET DEFAULT nextval('public.branches_id_seq'::regclass);


--
-- Name: broadcasts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.broadcasts ALTER COLUMN id SET DEFAULT nextval('public.broadcasts_id_seq'::regclass);


--
-- Name: build_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.build_configs ALTER COLUMN id SET DEFAULT nextval('public.build_configs_id_seq'::regclass);


--
-- Name: commits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commits ALTER COLUMN id SET DEFAULT nextval('public.commits_id_seq'::regclass);


--
-- Name: coupons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coupons ALTER COLUMN id SET DEFAULT nextval('public.coupons_id_seq'::regclass);


--
-- Name: crons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crons ALTER COLUMN id SET DEFAULT nextval('public.crons_id_seq'::regclass);


--
-- Name: emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails ALTER COLUMN id SET DEFAULT nextval('public.emails_id_seq'::regclass);


--
-- Name: installations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.installations ALTER COLUMN id SET DEFAULT nextval('public.installations_id_seq'::regclass);


--
-- Name: invoices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices ALTER COLUMN id SET DEFAULT nextval('public.invoices_id_seq'::regclass);


--
-- Name: job_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_configs ALTER COLUMN id SET DEFAULT nextval('public.job_configs_id_seq'::regclass);


--
-- Name: memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships ALTER COLUMN id SET DEFAULT nextval('public.memberships_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: owner_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.owner_groups ALTER COLUMN id SET DEFAULT nextval('public.owner_groups_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: pull_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pull_requests ALTER COLUMN id SET DEFAULT nextval('public.pull_requests_id_seq'::regclass);


--
-- Name: queueable_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.queueable_jobs ALTER COLUMN id SET DEFAULT nextval('public.queueable_jobs_id_seq'::regclass);


--
-- Name: repositories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories ALTER COLUMN id SET DEFAULT nextval('public.repositories_id_seq'::regclass);


--
-- Name: request_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_configs ALTER COLUMN id SET DEFAULT nextval('public.request_configs_id_seq'::regclass);


--
-- Name: request_payloads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_payloads ALTER COLUMN id SET DEFAULT nextval('public.request_payloads_id_seq'::regclass);


--
-- Name: requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requests ALTER COLUMN id SET DEFAULT nextval('public.requests_id_seq'::regclass);


--
-- Name: ssl_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ssl_keys ALTER COLUMN id SET DEFAULT nextval('public.ssl_keys_id_seq'::regclass);


--
-- Name: stages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stages ALTER COLUMN id SET DEFAULT nextval('public.stages_id_seq'::regclass);


--
-- Name: stars id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stars ALTER COLUMN id SET DEFAULT nextval('public.stars_id_seq'::regclass);


--
-- Name: stripe_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_events ALTER COLUMN id SET DEFAULT nextval('public.stripe_events_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens ALTER COLUMN id SET DEFAULT nextval('public.tokens_id_seq'::regclass);


--
-- Name: trial_allowances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trial_allowances ALTER COLUMN id SET DEFAULT nextval('public.trial_allowances_id_seq'::regclass);


--
-- Name: trials id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trials ALTER COLUMN id SET DEFAULT nextval('public.trials_id_seq'::regclass);


--
-- Name: urls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.urls ALTER COLUMN id SET DEFAULT nextval('public.urls_id_seq'::regclass);


--
-- Name: user_beta_features id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_beta_features ALTER COLUMN id SET DEFAULT nextval('public.user_beta_features_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: abuses abuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.abuses
    ADD CONSTRAINT abuses_pkey PRIMARY KEY (id);


--
-- Name: beta_features beta_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.beta_features
    ADD CONSTRAINT beta_features_pkey PRIMARY KEY (id);


--
-- Name: branches branches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (id);


--
-- Name: broadcasts broadcasts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.broadcasts
    ADD CONSTRAINT broadcasts_pkey PRIMARY KEY (id);


--
-- Name: build_configs build_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.build_configs
    ADD CONSTRAINT build_configs_pkey PRIMARY KEY (id);


--
-- Name: builds builds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.builds
    ADD CONSTRAINT builds_pkey PRIMARY KEY (id);


--
-- Name: commits commits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commits
    ADD CONSTRAINT commits_pkey PRIMARY KEY (id);


--
-- Name: coupons coupons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coupons
    ADD CONSTRAINT coupons_pkey PRIMARY KEY (id);


--
-- Name: crons crons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crons
    ADD CONSTRAINT crons_pkey PRIMARY KEY (id);


--
-- Name: emails emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: installations installations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.installations
    ADD CONSTRAINT installations_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: job_configs job_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_configs
    ADD CONSTRAINT job_configs_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: owner_groups owner_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.owner_groups
    ADD CONSTRAINT owner_groups_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: pull_requests pull_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pull_requests
    ADD CONSTRAINT pull_requests_pkey PRIMARY KEY (id);


--
-- Name: queueable_jobs queueable_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.queueable_jobs
    ADD CONSTRAINT queueable_jobs_pkey PRIMARY KEY (id);


--
-- Name: repositories repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories
    ADD CONSTRAINT repositories_pkey PRIMARY KEY (id);


--
-- Name: request_configs request_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_configs
    ADD CONSTRAINT request_configs_pkey PRIMARY KEY (id);


--
-- Name: request_payloads request_payloads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_payloads
    ADD CONSTRAINT request_payloads_pkey PRIMARY KEY (id);


--
-- Name: requests requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT requests_pkey PRIMARY KEY (id);


--
-- Name: ssl_keys ssl_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ssl_keys
    ADD CONSTRAINT ssl_keys_pkey PRIMARY KEY (id);


--
-- Name: stages stages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stages
    ADD CONSTRAINT stages_pkey PRIMARY KEY (id);


--
-- Name: stars stars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stars
    ADD CONSTRAINT stars_pkey PRIMARY KEY (id);


--
-- Name: stripe_events stripe_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_events
    ADD CONSTRAINT stripe_events_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- Name: trial_allowances trial_allowances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trial_allowances
    ADD CONSTRAINT trial_allowances_pkey PRIMARY KEY (id);


--
-- Name: trials trials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trials
    ADD CONSTRAINT trials_pkey PRIMARY KEY (id);


--
-- Name: urls urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.urls
    ADD CONSTRAINT urls_pkey PRIMARY KEY (id);


--
-- Name: user_beta_features user_beta_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_beta_features
    ADD CONSTRAINT user_beta_features_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_abuses_on_owner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_abuses_on_owner ON public.abuses USING btree (owner_id);


--
-- Name: index_abuses_on_owner_id_and_owner_type_and_level; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_abuses_on_owner_id_and_owner_type_and_level ON public.abuses USING btree (owner_id, owner_type, level);


--
-- Name: index_branches_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_branches_on_com_id ON public.branches USING btree (com_id);


--
-- Name: index_branches_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_branches_on_org_id ON public.branches USING btree (org_id);


--
-- Name: index_branches_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_branches_on_repository_id ON public.branches USING btree (repository_id);


--
-- Name: index_branches_on_repository_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_branches_on_repository_id_and_name ON public.branches USING btree (repository_id, name);


--
-- Name: index_broadcasts_on_recipient_id_and_recipient_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_broadcasts_on_recipient_id_and_recipient_type ON public.broadcasts USING btree (recipient_id, recipient_type);


--
-- Name: index_build_configs_on_repository_id_and_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_build_configs_on_repository_id_and_key ON public.build_configs USING btree (repository_id, key);


--
-- Name: index_builds_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_builds_on_com_id ON public.builds USING btree (com_id);


--
-- Name: index_builds_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_builds_on_org_id ON public.builds USING btree (org_id);


--
-- Name: index_builds_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_repository_id ON public.builds USING btree (repository_id);


--
-- Name: index_builds_on_repository_id_and_branch_and_event_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_repository_id_and_branch_and_event_type ON public.builds USING btree (repository_id, branch, event_type) WHERE ((state)::text = ANY ((ARRAY['created'::character varying, 'queued'::character varying, 'received'::character varying])::text[]));


--
-- Name: index_builds_on_repository_id_and_branch_and_event_type_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_repository_id_and_branch_and_event_type_and_id ON public.builds USING btree (repository_id, branch, event_type, id);


--
-- Name: index_builds_on_repository_id_and_branch_and_id_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_repository_id_and_branch_and_id_desc ON public.builds USING btree (repository_id, branch, id DESC);


--
-- Name: index_builds_on_repository_id_and_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_repository_id_and_number ON public.builds USING btree (repository_id, ((number)::integer));


--
-- Name: index_builds_on_repository_id_and_number_and_event_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_repository_id_and_number_and_event_type ON public.builds USING btree (repository_id, number, event_type);


--
-- Name: index_builds_on_repository_id_where_state_not_finished; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_repository_id_where_state_not_finished ON public.builds USING btree (repository_id) WHERE ((state)::text = ANY ((ARRAY['created'::character varying, 'queued'::character varying, 'received'::character varying, 'started'::character varying])::text[]));


--
-- Name: index_builds_on_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_request_id ON public.builds USING btree (request_id);


--
-- Name: index_builds_on_sender_type_and_sender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_sender_type_and_sender_id ON public.builds USING btree (sender_type, sender_id);


--
-- Name: index_builds_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_builds_on_state ON public.builds USING btree (state);


--
-- Name: index_commits_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_commits_on_com_id ON public.commits USING btree (com_id);


--
-- Name: index_commits_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_commits_on_org_id ON public.commits USING btree (org_id);


--
-- Name: index_crons_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_crons_on_com_id ON public.crons USING btree (com_id);


--
-- Name: index_crons_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_crons_on_org_id ON public.crons USING btree (org_id);


--
-- Name: index_emails_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_email ON public.emails USING btree (email);


--
-- Name: index_emails_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_user_id ON public.emails USING btree (user_id);


--
-- Name: index_installations_on_added_by_id_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_installations_on_added_by_id_id ON public.installations USING btree (added_by_id_id);


--
-- Name: index_installations_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_installations_on_owner_id ON public.installations USING btree (owner_id);


--
-- Name: index_installations_on_owner_id_and_owner_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_installations_on_owner_id_and_owner_type ON public.installations USING btree (owner_id, owner_type);


--
-- Name: index_installations_on_removed_by_id_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_installations_on_removed_by_id_id ON public.installations USING btree (removed_by_id_id);


--
-- Name: index_invoices_on_stripe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invoices_on_stripe_id ON public.invoices USING btree (stripe_id);


--
-- Name: index_job_configs_on_repository_id_and_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_configs_on_repository_id_and_key ON public.job_configs USING btree (repository_id, key);


--
-- Name: index_jobs_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_jobs_on_com_id ON public.jobs USING btree (com_id);


--
-- Name: index_jobs_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_created_at ON public.jobs USING btree (created_at);


--
-- Name: index_jobs_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_jobs_on_org_id ON public.jobs USING btree (org_id);


--
-- Name: index_jobs_on_owner_id_and_owner_type_and_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_owner_id_and_owner_type_and_state ON public.jobs USING btree (owner_id, owner_type, state);


--
-- Name: index_jobs_on_repository_id_where_state_running; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_repository_id_where_state_running ON public.jobs USING btree (repository_id) WHERE ((state)::text = ANY ((ARRAY['queued'::character varying, 'received'::character varying, 'started'::character varying])::text[]));


--
-- Name: index_jobs_on_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_source_id ON public.jobs USING btree (source_id);


--
-- Name: index_jobs_on_stage_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_stage_id ON public.jobs USING btree (stage_id);


--
-- Name: index_jobs_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_state ON public.jobs USING btree (state);


--
-- Name: index_jobs_on_type_and_source_id_and_source_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_type_and_source_id_and_source_type ON public.jobs USING btree (type, source_id, source_type);


--
-- Name: index_jobs_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_updated_at ON public.jobs USING btree (updated_at);


--
-- Name: index_memberships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_user_id ON public.memberships USING btree (user_id);


--
-- Name: index_messages_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_messages_on_subject_type_and_subject_id ON public.messages USING btree (subject_type, subject_id);


--
-- Name: index_organizations_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_com_id ON public.organizations USING btree (com_id);


--
-- Name: index_organizations_on_github_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_github_id ON public.organizations USING btree (github_id);


--
-- Name: index_organizations_on_login; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_login ON public.organizations USING btree (login);


--
-- Name: index_organizations_on_lower_login; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organizations_on_lower_login ON public.organizations USING btree (lower((login)::text));


--
-- Name: index_organizations_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_org_id ON public.organizations USING btree (org_id);


--
-- Name: index_owner_groups_on_owner_type_and_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_owner_groups_on_owner_type_and_owner_id ON public.owner_groups USING btree (owner_type, owner_id);


--
-- Name: index_owner_groups_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_owner_groups_on_uuid ON public.owner_groups USING btree (uuid);


--
-- Name: index_permissions_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permissions_on_com_id ON public.permissions USING btree (com_id);


--
-- Name: index_permissions_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permissions_on_org_id ON public.permissions USING btree (org_id);


--
-- Name: index_permissions_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_on_repository_id ON public.permissions USING btree (repository_id);


--
-- Name: index_permissions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_on_user_id ON public.permissions USING btree (user_id);


--
-- Name: index_permissions_on_user_id_and_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permissions_on_user_id_and_repository_id ON public.permissions USING btree (user_id, repository_id);


--
-- Name: index_pull_requests_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pull_requests_on_com_id ON public.pull_requests USING btree (com_id);


--
-- Name: index_pull_requests_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pull_requests_on_org_id ON public.pull_requests USING btree (org_id);


--
-- Name: index_pull_requests_on_repository_id_and_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pull_requests_on_repository_id_and_number ON public.pull_requests USING btree (repository_id, number);


--
-- Name: index_queueable_jobs_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_queueable_jobs_on_job_id ON public.queueable_jobs USING btree (job_id);


--
-- Name: index_repo_counts_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repo_counts_on_repository_id ON public.repo_counts USING btree (repository_id);


--
-- Name: index_repositories_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_active ON public.repositories USING btree (active);


--
-- Name: index_repositories_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_repositories_on_com_id ON public.repositories USING btree (com_id);


--
-- Name: index_repositories_on_github_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_repositories_on_github_id ON public.repositories USING btree (github_id);


--
-- Name: index_repositories_on_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_lower_name ON public.repositories USING btree (lower((name)::text));


--
-- Name: index_repositories_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_name ON public.repositories USING btree (name);


--
-- Name: index_repositories_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_repositories_on_org_id ON public.repositories USING btree (org_id);


--
-- Name: index_repositories_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_owner_id ON public.repositories USING btree (owner_id);


--
-- Name: index_repositories_on_owner_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_owner_name ON public.repositories USING btree (owner_name);


--
-- Name: index_repositories_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_slug ON public.repositories USING gin (((((owner_name)::text || '/'::text) || (name)::text)) public.gin_trgm_ops);


--
-- Name: index_request_configs_on_repository_id_and_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_request_configs_on_repository_id_and_key ON public.request_configs USING btree (repository_id, key);


--
-- Name: index_request_payloads_on_created_at_and_archived; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_request_payloads_on_created_at_and_archived ON public.request_payloads USING btree (created_at, archived);


--
-- Name: index_request_payloads_on_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_request_payloads_on_request_id ON public.request_payloads USING btree (request_id);


--
-- Name: index_requests_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_requests_on_com_id ON public.requests USING btree (com_id);


--
-- Name: index_requests_on_commit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requests_on_commit_id ON public.requests USING btree (commit_id);


--
-- Name: index_requests_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requests_on_created_at ON public.requests USING btree (created_at);


--
-- Name: index_requests_on_head_commit; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requests_on_head_commit ON public.requests USING btree (head_commit);


--
-- Name: index_requests_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_requests_on_org_id ON public.requests USING btree (org_id);


--
-- Name: index_requests_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requests_on_repository_id ON public.requests USING btree (repository_id);


--
-- Name: index_requests_on_repository_id_and_id_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_requests_on_repository_id_and_id_desc ON public.requests USING btree (repository_id, id DESC);


--
-- Name: index_ssl_key_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ssl_key_on_repository_id ON public.ssl_keys USING btree (repository_id);


--
-- Name: index_ssl_keys_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ssl_keys_on_com_id ON public.ssl_keys USING btree (com_id);


--
-- Name: index_ssl_keys_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ssl_keys_on_org_id ON public.ssl_keys USING btree (org_id);


--
-- Name: index_stages_on_build_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stages_on_build_id ON public.stages USING btree (build_id);


--
-- Name: index_stages_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stages_on_com_id ON public.stages USING btree (com_id);


--
-- Name: index_stages_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stages_on_org_id ON public.stages USING btree (org_id);


--
-- Name: index_stars_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stars_on_user_id ON public.stars USING btree (user_id);


--
-- Name: index_stars_on_user_id_and_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stars_on_user_id_and_repository_id ON public.stars USING btree (user_id, repository_id);


--
-- Name: index_stripe_events_on_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_events_on_date ON public.stripe_events USING btree (date);


--
-- Name: index_stripe_events_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_events_on_event_id ON public.stripe_events USING btree (event_id);


--
-- Name: index_stripe_events_on_event_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stripe_events_on_event_type ON public.stripe_events USING btree (event_type);


--
-- Name: index_tags_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_com_id ON public.tags USING btree (com_id);


--
-- Name: index_tags_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_org_id ON public.tags USING btree (org_id);


--
-- Name: index_tags_on_repository_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_repository_id_and_name ON public.tags USING btree (repository_id, name);


--
-- Name: index_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tokens_on_token ON public.tokens USING btree (token);


--
-- Name: index_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tokens_on_user_id ON public.tokens USING btree (user_id);


--
-- Name: index_trial_allowances_on_creator_id_and_creator_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trial_allowances_on_creator_id_and_creator_type ON public.trial_allowances USING btree (creator_id, creator_type);


--
-- Name: index_trial_allowances_on_trial_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trial_allowances_on_trial_id ON public.trial_allowances USING btree (trial_id);


--
-- Name: index_trials_on_owner; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trials_on_owner ON public.trials USING btree (owner_id, owner_type);


--
-- Name: index_user_beta_features_on_user_id_and_beta_feature_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_beta_features_on_user_id_and_beta_feature_id ON public.user_beta_features USING btree (user_id, beta_feature_id);


--
-- Name: index_users_on_com_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_com_id ON public.users USING btree (com_id);


--
-- Name: index_users_on_github_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_github_id ON public.users USING btree (github_id);


--
-- Name: index_users_on_github_oauth_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_github_oauth_token ON public.users USING btree (github_oauth_token);


--
-- Name: index_users_on_login; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_login ON public.users USING btree (login);


--
-- Name: index_users_on_lower_login; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_lower_login ON public.users USING btree (lower((login)::text));


--
-- Name: index_users_on_org_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_org_id ON public.users USING btree (org_id);


--
-- Name: subscriptions_owner; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX subscriptions_owner ON public.subscriptions USING btree (owner_id, owner_type) WHERE ((status)::text = 'subscribed'::text);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: builds set_updated_at_on_builds; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_at_on_builds BEFORE INSERT OR UPDATE ON public.builds FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();


--
-- Name: jobs set_updated_at_on_jobs; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_at_on_jobs BEFORE INSERT OR UPDATE ON public.jobs FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();


--
-- Name: branches trg_count_branch_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_branch_deleted AFTER DELETE ON public.branches FOR EACH ROW WHEN ((now() > '2018-01-01 01:00:00+01'::timestamp with time zone)) EXECUTE PROCEDURE public.count_branches('-1');


--
-- Name: branches trg_count_branch_inserted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_branch_inserted AFTER INSERT ON public.branches FOR EACH ROW WHEN ((now() > '2018-01-01 01:00:00+01'::timestamp with time zone)) EXECUTE PROCEDURE public.count_branches('1');


--
-- Name: builds trg_count_build_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_build_deleted AFTER DELETE ON public.builds FOR EACH ROW WHEN ((now() > '2018-01-01 01:00:00+01'::timestamp with time zone)) EXECUTE PROCEDURE public.count_builds('-1');


--
-- Name: builds trg_count_build_inserted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_build_inserted AFTER INSERT ON public.builds FOR EACH ROW WHEN ((now() > '2018-01-01 01:00:00+01'::timestamp with time zone)) EXECUTE PROCEDURE public.count_builds('1');


--
-- Name: commits trg_count_commit_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_commit_deleted AFTER DELETE ON public.commits FOR EACH ROW WHEN ((now() > '2018-01-01 01:00:00+01'::timestamp with time zone)) EXECUTE PROCEDURE public.count_commits('-1');


--
-- Name: commits trg_count_commit_inserted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_commit_inserted AFTER INSERT ON public.commits FOR EACH ROW WHEN ((now() > '2018-01-01 01:00:00+01'::timestamp with time zone)) EXECUTE PROCEDURE public.count_commits('1');


--
-- Name: jobs trg_count_job_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_job_deleted AFTER DELETE ON public.jobs FOR EACH ROW WHEN ((now() > '2018-01-01 01:00:00+01'::timestamp with time zone)) EXECUTE PROCEDURE public.count_jobs('-1');


--
-- Name: jobs trg_count_job_inserted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_job_inserted AFTER INSERT ON public.jobs FOR EACH ROW WHEN ((now() > '2018-01-01 01:00:00+01'::timestamp with time zone)) EXECUTE PROCEDURE public.count_jobs('1');


--
-- Name: pull_requests trg_count_pull_request_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_pull_request_deleted AFTER DELETE ON public.pull_requests FOR EACH ROW WHEN ((now() > '2018-01-01 01:00:00+01'::timestamp with time zone)) EXECUTE PROCEDURE public.count_pull_requests('-1');


--
-- Name: pull_requests trg_count_pull_request_inserted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_pull_request_inserted AFTER INSERT ON public.pull_requests FOR EACH ROW WHEN ((now() > '2018-01-01 01:00:00+01'::timestamp with time zone)) EXECUTE PROCEDURE public.count_pull_requests('1');


--
-- Name: requests trg_count_request_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_request_deleted AFTER DELETE ON public.requests FOR EACH ROW WHEN ((now() > '2018-01-01 01:00:00+01'::timestamp with time zone)) EXECUTE PROCEDURE public.count_requests('-1');


--
-- Name: requests trg_count_request_inserted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_request_inserted AFTER INSERT ON public.requests FOR EACH ROW WHEN ((now() > '2018-01-01 01:00:00+01'::timestamp with time zone)) EXECUTE PROCEDURE public.count_requests('1');


--
-- Name: tags trg_count_tag_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_tag_deleted AFTER DELETE ON public.tags FOR EACH ROW WHEN ((now() > '2018-01-01 01:00:00+01'::timestamp with time zone)) EXECUTE PROCEDURE public.count_tags('-1');


--
-- Name: tags trg_count_tag_inserted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_count_tag_inserted AFTER INSERT ON public.tags FOR EACH ROW WHEN ((now() > '2018-01-01 01:00:00+01'::timestamp with time zone)) EXECUTE PROCEDURE public.count_tags('1');


--
-- Name: installations fk_rails_2d567d406d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.installations
    ADD CONSTRAINT fk_rails_2d567d406d FOREIGN KEY (added_by_id) REFERENCES public.users(id);


--
-- Name: installations fk_rails_75a0a2a3b4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.installations
    ADD CONSTRAINT fk_rails_75a0a2a3b4 FOREIGN KEY (removed_by_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20101126174706');

INSERT INTO schema_migrations (version) VALUES ('20101126174715');

INSERT INTO schema_migrations (version) VALUES ('20110109130532');

INSERT INTO schema_migrations (version) VALUES ('20110116155100');

INSERT INTO schema_migrations (version) VALUES ('20110130102621');

INSERT INTO schema_migrations (version) VALUES ('20110301071656');

INSERT INTO schema_migrations (version) VALUES ('20110316174721');

INSERT INTO schema_migrations (version) VALUES ('20110321075539');

INSERT INTO schema_migrations (version) VALUES ('20110411171936');

INSERT INTO schema_migrations (version) VALUES ('20110411171937');

INSERT INTO schema_migrations (version) VALUES ('20110411172518');

INSERT INTO schema_migrations (version) VALUES ('20110413101057');

INSERT INTO schema_migrations (version) VALUES ('20110414131100');

INSERT INTO schema_migrations (version) VALUES ('20110503150504');

INSERT INTO schema_migrations (version) VALUES ('20110523012243');

INSERT INTO schema_migrations (version) VALUES ('20110611203537');

INSERT INTO schema_migrations (version) VALUES ('20110613210252');

INSERT INTO schema_migrations (version) VALUES ('20110615152003');

INSERT INTO schema_migrations (version) VALUES ('20110616211744');

INSERT INTO schema_migrations (version) VALUES ('20110617114728');

INSERT INTO schema_migrations (version) VALUES ('20110619100906');

INSERT INTO schema_migrations (version) VALUES ('20110729094426');

INSERT INTO schema_migrations (version) VALUES ('20110801161819');

INSERT INTO schema_migrations (version) VALUES ('20110805030147');

INSERT INTO schema_migrations (version) VALUES ('20110819232908');

INSERT INTO schema_migrations (version) VALUES ('20110911204538');

INSERT INTO schema_migrations (version) VALUES ('20111107134436');

INSERT INTO schema_migrations (version) VALUES ('20111107134437');

INSERT INTO schema_migrations (version) VALUES ('20111107134438');

INSERT INTO schema_migrations (version) VALUES ('20111107134439');

INSERT INTO schema_migrations (version) VALUES ('20111107134440');

INSERT INTO schema_migrations (version) VALUES ('20111128235043');

INSERT INTO schema_migrations (version) VALUES ('20111129014329');

INSERT INTO schema_migrations (version) VALUES ('20111129022625');

INSERT INTO schema_migrations (version) VALUES ('20111201113500');

INSERT INTO schema_migrations (version) VALUES ('20111203002341');

INSERT INTO schema_migrations (version) VALUES ('20111203221720');

INSERT INTO schema_migrations (version) VALUES ('20111207093700');

INSERT INTO schema_migrations (version) VALUES ('20111212103859');

INSERT INTO schema_migrations (version) VALUES ('20111212112411');

INSERT INTO schema_migrations (version) VALUES ('20111214173922');

INSERT INTO schema_migrations (version) VALUES ('20120114125404');

INSERT INTO schema_migrations (version) VALUES ('20120216133223');

INSERT INTO schema_migrations (version) VALUES ('20120222082522');

INSERT INTO schema_migrations (version) VALUES ('20120301131209');

INSERT INTO schema_migrations (version) VALUES ('20120304000502');

INSERT INTO schema_migrations (version) VALUES ('20120304000503');

INSERT INTO schema_migrations (version) VALUES ('20120304000504');

INSERT INTO schema_migrations (version) VALUES ('20120304000505');

INSERT INTO schema_migrations (version) VALUES ('20120304000506');

INSERT INTO schema_migrations (version) VALUES ('20120311234933');

INSERT INTO schema_migrations (version) VALUES ('20120316123726');

INSERT INTO schema_migrations (version) VALUES ('20120319170001');

INSERT INTO schema_migrations (version) VALUES ('20120324104051');

INSERT INTO schema_migrations (version) VALUES ('20120505165100');

INSERT INTO schema_migrations (version) VALUES ('20120511171900');

INSERT INTO schema_migrations (version) VALUES ('20120521174400');

INSERT INTO schema_migrations (version) VALUES ('20120527235800');

INSERT INTO schema_migrations (version) VALUES ('20120702111126');

INSERT INTO schema_migrations (version) VALUES ('20120703114226');

INSERT INTO schema_migrations (version) VALUES ('20120713140816');

INSERT INTO schema_migrations (version) VALUES ('20120713153215');

INSERT INTO schema_migrations (version) VALUES ('20120725005300');

INSERT INTO schema_migrations (version) VALUES ('201207261749');

INSERT INTO schema_migrations (version) VALUES ('20120727151900');

INSERT INTO schema_migrations (version) VALUES ('20120731005301');

INSERT INTO schema_migrations (version) VALUES ('20120731074000');

INSERT INTO schema_migrations (version) VALUES ('20120802001001');

INSERT INTO schema_migrations (version) VALUES ('20120803164000');

INSERT INTO schema_migrations (version) VALUES ('20120803182300');

INSERT INTO schema_migrations (version) VALUES ('20120804122700');

INSERT INTO schema_migrations (version) VALUES ('20120806120400');

INSERT INTO schema_migrations (version) VALUES ('20120820164000');

INSERT INTO schema_migrations (version) VALUES ('20120905093300');

INSERT INTO schema_migrations (version) VALUES ('20120905171300');

INSERT INTO schema_migrations (version) VALUES ('20120911160000');

INSERT INTO schema_migrations (version) VALUES ('20120911230000');

INSERT INTO schema_migrations (version) VALUES ('20120911230001');

INSERT INTO schema_migrations (version) VALUES ('20120913143800');

INSERT INTO schema_migrations (version) VALUES ('20120915012000');

INSERT INTO schema_migrations (version) VALUES ('20120915012001');

INSERT INTO schema_migrations (version) VALUES ('20120915150000');

INSERT INTO schema_migrations (version) VALUES ('20121015002500');

INSERT INTO schema_migrations (version) VALUES ('20121015002501');

INSERT INTO schema_migrations (version) VALUES ('20121017040100');

INSERT INTO schema_migrations (version) VALUES ('20121017040200');

INSERT INTO schema_migrations (version) VALUES ('20121018201301');

INSERT INTO schema_migrations (version) VALUES ('20121018203728');

INSERT INTO schema_migrations (version) VALUES ('20121018210156');

INSERT INTO schema_migrations (version) VALUES ('20121125122700');

INSERT INTO schema_migrations (version) VALUES ('20121125122701');

INSERT INTO schema_migrations (version) VALUES ('20121222125200');

INSERT INTO schema_migrations (version) VALUES ('20121222125300');

INSERT INTO schema_migrations (version) VALUES ('20121222140200');

INSERT INTO schema_migrations (version) VALUES ('20121223162300');

INSERT INTO schema_migrations (version) VALUES ('20130107165057');

INSERT INTO schema_migrations (version) VALUES ('20130115125836');

INSERT INTO schema_migrations (version) VALUES ('20130115145728');

INSERT INTO schema_migrations (version) VALUES ('20130125002600');

INSERT INTO schema_migrations (version) VALUES ('20130125171100');

INSERT INTO schema_migrations (version) VALUES ('20130129142703');

INSERT INTO schema_migrations (version) VALUES ('20130208135800');

INSERT INTO schema_migrations (version) VALUES ('20130208135801');

INSERT INTO schema_migrations (version) VALUES ('20130306154311');

INSERT INTO schema_migrations (version) VALUES ('20130311211101');

INSERT INTO schema_migrations (version) VALUES ('20130327100801');

INSERT INTO schema_migrations (version) VALUES ('20130418101437');

INSERT INTO schema_migrations (version) VALUES ('20130418103306');

INSERT INTO schema_migrations (version) VALUES ('20130504230850');

INSERT INTO schema_migrations (version) VALUES ('20130505023259');

INSERT INTO schema_migrations (version) VALUES ('20130521115725');

INSERT INTO schema_migrations (version) VALUES ('20130521133050');

INSERT INTO schema_migrations (version) VALUES ('20130521134224');

INSERT INTO schema_migrations (version) VALUES ('20130521134800');

INSERT INTO schema_migrations (version) VALUES ('20130521141357');

INSERT INTO schema_migrations (version) VALUES ('20130618084205');

INSERT INTO schema_migrations (version) VALUES ('20130629122945');

INSERT INTO schema_migrations (version) VALUES ('20130629133531');

INSERT INTO schema_migrations (version) VALUES ('20130629174449');

INSERT INTO schema_migrations (version) VALUES ('20130701175200');

INSERT INTO schema_migrations (version) VALUES ('20130702123456');

INSERT INTO schema_migrations (version) VALUES ('20130702144325');

INSERT INTO schema_migrations (version) VALUES ('20130705123456');

INSERT INTO schema_migrations (version) VALUES ('20130707164854');

INSERT INTO schema_migrations (version) VALUES ('20130709185200');

INSERT INTO schema_migrations (version) VALUES ('20130709233500');

INSERT INTO schema_migrations (version) VALUES ('20130710000745');

INSERT INTO schema_migrations (version) VALUES ('20130726101124');

INSERT INTO schema_migrations (version) VALUES ('20130901183019');

INSERT INTO schema_migrations (version) VALUES ('20130909203321');

INSERT INTO schema_migrations (version) VALUES ('20130910184823');

INSERT INTO schema_migrations (version) VALUES ('20130916101056');

INSERT INTO schema_migrations (version) VALUES ('20130920135744');

INSERT INTO schema_migrations (version) VALUES ('20131104101056');

INSERT INTO schema_migrations (version) VALUES ('20131109101056');

INSERT INTO schema_migrations (version) VALUES ('20140120225125');

INSERT INTO schema_migrations (version) VALUES ('20140121003026');

INSERT INTO schema_migrations (version) VALUES ('20140204220926');

INSERT INTO schema_migrations (version) VALUES ('20140210003014');

INSERT INTO schema_migrations (version) VALUES ('20140210012509');

INSERT INTO schema_migrations (version) VALUES ('20140612131826');

INSERT INTO schema_migrations (version) VALUES ('20140827121945');

INSERT INTO schema_migrations (version) VALUES ('20150121135400');

INSERT INTO schema_migrations (version) VALUES ('20150121135401');

INSERT INTO schema_migrations (version) VALUES ('20150204144312');

INSERT INTO schema_migrations (version) VALUES ('20150210170900');

INSERT INTO schema_migrations (version) VALUES ('20150223125700');

INSERT INTO schema_migrations (version) VALUES ('20150311020321');

INSERT INTO schema_migrations (version) VALUES ('20150316020321');

INSERT INTO schema_migrations (version) VALUES ('20150316080321');

INSERT INTO schema_migrations (version) VALUES ('20150316100321');

INSERT INTO schema_migrations (version) VALUES ('20150317004600');

INSERT INTO schema_migrations (version) VALUES ('20150317020321');

INSERT INTO schema_migrations (version) VALUES ('20150317080321');

INSERT INTO schema_migrations (version) VALUES ('20150414001337');

INSERT INTO schema_migrations (version) VALUES ('20150528101600');

INSERT INTO schema_migrations (version) VALUES ('20150528101601');

INSERT INTO schema_migrations (version) VALUES ('20150528101602');

INSERT INTO schema_migrations (version) VALUES ('20150528101603');

INSERT INTO schema_migrations (version) VALUES ('20150528101604');

INSERT INTO schema_migrations (version) VALUES ('20150528101605');

INSERT INTO schema_migrations (version) VALUES ('20150528101607');

INSERT INTO schema_migrations (version) VALUES ('20150528101608');

INSERT INTO schema_migrations (version) VALUES ('20150528101609');

INSERT INTO schema_migrations (version) VALUES ('20150528101610');

INSERT INTO schema_migrations (version) VALUES ('20150528101611');

INSERT INTO schema_migrations (version) VALUES ('20150609175200');

INSERT INTO schema_migrations (version) VALUES ('20150610143500');

INSERT INTO schema_migrations (version) VALUES ('20150610143501');

INSERT INTO schema_migrations (version) VALUES ('20150610143502');

INSERT INTO schema_migrations (version) VALUES ('20150610143503');

INSERT INTO schema_migrations (version) VALUES ('20150610143504');

INSERT INTO schema_migrations (version) VALUES ('20150610143505');

INSERT INTO schema_migrations (version) VALUES ('20150610143506');

INSERT INTO schema_migrations (version) VALUES ('20150610143507');

INSERT INTO schema_migrations (version) VALUES ('20150610143508');

INSERT INTO schema_migrations (version) VALUES ('20150610143509');

INSERT INTO schema_migrations (version) VALUES ('20150610143510');

INSERT INTO schema_migrations (version) VALUES ('20150615103059');

INSERT INTO schema_migrations (version) VALUES ('20150629231300');

INSERT INTO schema_migrations (version) VALUES ('20150923131400');

INSERT INTO schema_migrations (version) VALUES ('20151112153500');

INSERT INTO schema_migrations (version) VALUES ('20151113111400');

INSERT INTO schema_migrations (version) VALUES ('20151127153500');

INSERT INTO schema_migrations (version) VALUES ('20151127154200');

INSERT INTO schema_migrations (version) VALUES ('20151127154600');

INSERT INTO schema_migrations (version) VALUES ('20151202122200');

INSERT INTO schema_migrations (version) VALUES ('20160107120927');

INSERT INTO schema_migrations (version) VALUES ('20160303165750');

INSERT INTO schema_migrations (version) VALUES ('20160412113020');

INSERT INTO schema_migrations (version) VALUES ('20160412113070');

INSERT INTO schema_migrations (version) VALUES ('20160412121405');

INSERT INTO schema_migrations (version) VALUES ('20160412123900');

INSERT INTO schema_migrations (version) VALUES ('20160414214442');

INSERT INTO schema_migrations (version) VALUES ('20160422104300');

INSERT INTO schema_migrations (version) VALUES ('20160422121400');

INSERT INTO schema_migrations (version) VALUES ('20160510142700');

INSERT INTO schema_migrations (version) VALUES ('20160510144200');

INSERT INTO schema_migrations (version) VALUES ('20160510150300');

INSERT INTO schema_migrations (version) VALUES ('20160510150400');

INSERT INTO schema_migrations (version) VALUES ('20160513074300');

INSERT INTO schema_migrations (version) VALUES ('20160609163600');

INSERT INTO schema_migrations (version) VALUES ('20160623133900');

INSERT INTO schema_migrations (version) VALUES ('20160623133901');

INSERT INTO schema_migrations (version) VALUES ('20160712125400');

INSERT INTO schema_migrations (version) VALUES ('20160819103700');

INSERT INTO schema_migrations (version) VALUES ('20160920220400');

INSERT INTO schema_migrations (version) VALUES ('20161028154600');

INSERT INTO schema_migrations (version) VALUES ('20161101000000');

INSERT INTO schema_migrations (version) VALUES ('20161101000001');

INSERT INTO schema_migrations (version) VALUES ('20161201112200');

INSERT INTO schema_migrations (version) VALUES ('20161201112600');

INSERT INTO schema_migrations (version) VALUES ('20161202000000');

INSERT INTO schema_migrations (version) VALUES ('20161206155800');

INSERT INTO schema_migrations (version) VALUES ('20161221171300');

INSERT INTO schema_migrations (version) VALUES ('20170211000000');

INSERT INTO schema_migrations (version) VALUES ('20170211000001');

INSERT INTO schema_migrations (version) VALUES ('20170211000002');

INSERT INTO schema_migrations (version) VALUES ('20170211000003');

INSERT INTO schema_migrations (version) VALUES ('20170213124000');

INSERT INTO schema_migrations (version) VALUES ('20170316000000');

INSERT INTO schema_migrations (version) VALUES ('20170316000001');

INSERT INTO schema_migrations (version) VALUES ('20170318000000');

INSERT INTO schema_migrations (version) VALUES ('20170318000001');

INSERT INTO schema_migrations (version) VALUES ('20170318000002');

INSERT INTO schema_migrations (version) VALUES ('20170322000000');

INSERT INTO schema_migrations (version) VALUES ('20170331000000');

INSERT INTO schema_migrations (version) VALUES ('20170401000000');

INSERT INTO schema_migrations (version) VALUES ('20170401000001');

INSERT INTO schema_migrations (version) VALUES ('20170401000002');

INSERT INTO schema_migrations (version) VALUES ('20170405000000');

INSERT INTO schema_migrations (version) VALUES ('20170405000001');

INSERT INTO schema_migrations (version) VALUES ('20170405000002');

INSERT INTO schema_migrations (version) VALUES ('20170405000003');

INSERT INTO schema_migrations (version) VALUES ('20170408000000');

INSERT INTO schema_migrations (version) VALUES ('20170408000001');

INSERT INTO schema_migrations (version) VALUES ('20170410000000');

INSERT INTO schema_migrations (version) VALUES ('20170411000000');

INSERT INTO schema_migrations (version) VALUES ('20170419093249');

INSERT INTO schema_migrations (version) VALUES ('20170531125700');

INSERT INTO schema_migrations (version) VALUES ('20170601163700');

INSERT INTO schema_migrations (version) VALUES ('20170601164400');

INSERT INTO schema_migrations (version) VALUES ('20170609174400');

INSERT INTO schema_migrations (version) VALUES ('20170613000000');

INSERT INTO schema_migrations (version) VALUES ('20170620144500');

INSERT INTO schema_migrations (version) VALUES ('20170621142300');

INSERT INTO schema_migrations (version) VALUES ('20170713162000');

INSERT INTO schema_migrations (version) VALUES ('20170822171600');

INSERT INTO schema_migrations (version) VALUES ('20170831000000');

INSERT INTO schema_migrations (version) VALUES ('20170911172800');

INSERT INTO schema_migrations (version) VALUES ('20171017104500');

INSERT INTO schema_migrations (version) VALUES ('20171024000000');

INSERT INTO schema_migrations (version) VALUES ('20171025000000');

INSERT INTO schema_migrations (version) VALUES ('20171103000000');

INSERT INTO schema_migrations (version) VALUES ('20171211000000');

INSERT INTO schema_migrations (version) VALUES ('20180212000000');

INSERT INTO schema_migrations (version) VALUES ('20180213000000');

INSERT INTO schema_migrations (version) VALUES ('20180222000000');

INSERT INTO schema_migrations (version) VALUES ('20180222000001');

INSERT INTO schema_migrations (version) VALUES ('20180222000002');

INSERT INTO schema_migrations (version) VALUES ('20180222000003');

INSERT INTO schema_migrations (version) VALUES ('20180222000009');

INSERT INTO schema_migrations (version) VALUES ('20180222000012');

INSERT INTO schema_migrations (version) VALUES ('20180222164100');

INSERT INTO schema_migrations (version) VALUES ('20180305143800');

INSERT INTO schema_migrations (version) VALUES ('20180321102400');

INSERT INTO schema_migrations (version) VALUES ('20180330000000');

INSERT INTO schema_migrations (version) VALUES ('20180331000000');

INSERT INTO schema_migrations (version) VALUES ('20180404000001');

INSERT INTO schema_migrations (version) VALUES ('20180404000002');

