--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.3
-- Dumped by pg_dump version 9.5.3

SET statement_timeout = 0;
SET lock_timeout = 0;
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


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: log_parts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE log_parts (
    id bigint NOT NULL,
    log_id integer NOT NULL,
    content text,
    number integer,
    final boolean,
    created_at timestamp without time zone
);


--
-- Name: log_parts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE log_parts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_parts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE log_parts_id_seq OWNED BY log_parts.id;


--
-- Name: logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE logs (
    id integer NOT NULL,
    job_id integer,
    content text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    aggregated_at timestamp without time zone,
    archived_at timestamp without time zone,
    purged_at timestamp without time zone,
    archiving boolean,
    archive_verified boolean,
    removed_by integer,
    removed_at timestamp without time zone
);


--
-- Name: logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE logs_id_seq OWNED BY logs.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    filename text NOT NULL
);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_parts ALTER COLUMN id SET DEFAULT nextval('log_parts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY logs ALTER COLUMN id SET DEFAULT nextval('logs_id_seq'::regclass);


--
-- Name: log_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY log_parts
    ADD CONSTRAINT log_parts_pkey PRIMARY KEY (id);


--
-- Name: logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (filename);


--
-- Name: index_log_parts_on_log_id_and_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_log_parts_on_log_id_and_number ON log_parts USING btree (log_id, number);


--
-- Name: index_logs_on_archive_verified; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_logs_on_archive_verified ON logs USING btree (archive_verified);


--
-- Name: index_logs_on_archived_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_logs_on_archived_at ON logs USING btree (archived_at);


--
-- Name: index_logs_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_logs_on_job_id ON logs USING btree (job_id);


--
-- Name: log_parts_created_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX log_parts_created_at_index ON log_parts USING btree (created_at);


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM renee;
GRANT ALL ON SCHEMA public TO renee;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

