DROP FUNCTION IF EXISTS soft_delete_repo_data(bigint);
CREATE FUNCTION soft_delete_repo_data(r_id bigint) RETURNS void AS $$
BEGIN
  -- don't check constraints until the end fo the transaction
  SET CONSTRAINTS ALL DEFERRED;

  WITH deleted_records AS (
    DELETE FROM crons WHERE branch_id IN (SELECT id FROM branches WHERE repository_id = r_id)
    RETURNING crons.*
  ) INSERT INTO deleted_crons SELECT * FROM deleted_records;
  WITH deleted_records AS (
    DELETE FROM jobs WHERE repository_id = r_id RETURNING jobs.*
  ) INSERT INTO deleted_jobs SELECT * FROM deleted_records;
  WITH deleted_records AS (
    DELETE FROM stages WHERE build_id IN (SELECT id FROM builds WHERE repository_id = r_id)
    RETURNING stages.*
  ) INSERT INTO deleted_stages SELECT * FROM deleted_records;
  WITH deleted_records AS (
    DELETE FROM request_payloads WHERE request_id IN (SELECT id FROM requests WHERE repository_id = r_id)
    RETURNING request_payloads.*
  ) INSERT INTO deleted_request_payloads SELECT * FROM deleted_records;
  WITH deleted_records AS (
    DELETE FROM requests WHERE repository_id = r_id RETURNING requests.*
  ) INSERT INTO deleted_requests SELECT * FROM deleted_records;
  WITH deleted_records AS (
    DELETE FROM commits WHERE repository_id = r_id RETURNING commits.*
  ) INSERT INTO deleted_commits SELECT * FROM deleted_records;
  WITH deleted_records AS (
    DELETE FROM pull_requests WHERE repository_id = r_id RETURNING pull_requests.*
  ) INSERT INTO deleted_pull_requests SELECT * FROM deleted_records;
  WITH deleted_records AS (
    DELETE FROM builds WHERE repository_id = r_id RETURNING builds.*
  ) INSERT INTO deleted_builds SELECT * FROM deleted_records;
  WITH deleted_records AS (
    DELETE FROM branches WHERE repository_id = r_id RETURNING branches.*
  ) INSERT INTO deleted_branches SELECT * FROM deleted_records;
  WITH deleted_records AS (
    DELETE FROM job_configs WHERE repository_id = r_id RETURNING job_configs.*
  ) INSERT INTO deleted_job_configs SELECT * FROM deleted_records;
  WITH deleted_records AS (
    DELETE FROM build_configs WHERE repository_id = r_id RETURNING build_configs.*
  ) INSERT INTO deleted_build_configs SELECT * FROM deleted_records;
  WITH deleted_records AS (
    DELETE FROM ssl_keys WHERE repository_id = r_id RETURNING ssl_keys.*
  ) INSERT INTO deleted_ssl_keys SELECT * FROM deleted_records;
  WITH deleted_records AS (
    DELETE FROM branches WHERE repository_id = r_id RETURNING branches.*
  ) INSERT INTO deleted_branches SELECT * FROM deleted_records;
  WITH deleted_records AS (
    DELETE FROM tags WHERE repository_id = r_id RETURNING tags.*
  ) INSERT INTO deleted_tags SELECT * FROM deleted_records;
  WITH deleted_records AS (
    DELETE FROM request_configs WHERE repository_id = r_id RETURNING request_configs.*
  ) INSERT INTO deleted_request_configs SELECT * FROM deleted_records;
END;
$$ LANGUAGE plpgsql;
