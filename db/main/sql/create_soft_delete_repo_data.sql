DROP FUNCTION IF EXISTS soft_delete_repo_data(bigint);
CREATE FUNCTION soft_delete_repo_data(r_id bigint) RETURNS void AS $$
DECLARE
  request_config_ids bigint[];
  tag_ids bigint[];
  ssl_key_ids bigint[];
  build_config_ids bigint[];
  job_config_ids bigint[];
  build_ids bigint[];
  pull_request_ids bigint[];
  commit_ids bigint[];
  request_ids bigint[];
  request_payload_ids bigint[];
  stage_ids bigint[];
  job_ids bigint[];
BEGIN
  SELECT INTO job_ids array_agg(id) FROM jobs WHERE repository_id = r_id;
  SELECT INTO stage_ids array_agg(id) FROM stages WHERE build_id IN (SELECT id FROM builds WHERE repository_id = r_id);
  SELECT INTO request_payload_ids array_agg(id) FROM request_payloads WHERE request_id IN (SELECT id FROM requests WHERE repository_id = r_id);
  SELECT INTO request_ids array_agg(id) FROM requests WHERE repository_id = r_id;
  SELECT INTO commit_ids array_agg(id) FROM commits WHERE repository_id = r_id;
  SELECT INTO pull_request_ids array_agg(id) FROM pull_requests WHERE repository_id = r_id;
  SELECT INTO build_ids array_agg(id) FROM builds WHERE repository_id = r_id;
  SELECT INTO job_config_ids array_agg(id) FROM job_configs WHERE repository_id = r_id;
  SELECT INTO build_config_ids array_agg(id) FROM build_configs WHERE repository_id = r_id;
  SELECT INTO ssl_key_ids array_agg(id) FROM ssl_keys WHERE repository_id = r_id;
  SELECT INTO tag_ids array_agg(id) FROM tags WHERE repository_id = r_id;
  SELECT INTO request_config_ids array_agg(id) FROM request_configs WHERE repository_id = r_id;

  INSERT INTO deleted_jobs SELECT * FROM jobs WHERE id = ANY(job_ids);
  INSERT INTO deleted_stages SELECT * FROM stages WHERE id = ANY(stage_ids);
  INSERT INTO deleted_request_payloads SELECT * FROM request_payloads WHERE id = ANY(request_payload_ids);
  INSERT INTO deleted_requests SELECT * FROM requests WHERE id = ANY(request_ids);
  INSERT INTO deleted_commits SELECT * FROM commits WHERE id = ANY(commit_ids);
  INSERT INTO deleted_pull_requests SELECT * FROM pull_requests WHERE id = ANY(pull_request_ids);
  INSERT INTO deleted_builds SELECT * FROM builds WHERE id = ANY(build_ids);
  INSERT INTO deleted_job_configs SELECT * FROM job_configs WHERE id = ANY(job_config_ids);
  INSERT INTO deleted_build_configs SELECT * FROM build_configs WHERE id = ANY(build_config_ids);
  INSERT INTO deleted_ssl_keys SELECT * FROM ssl_keys WHERE id = ANY(ssl_key_ids);
  INSERT INTO deleted_tags SELECT * FROM tags WHERE id = ANY(tag_ids);
  INSERT INTO deleted_request_configs SELECT * FROM request_configs WHERE id = ANY(request_config_ids);

  DELETE FROM jobs WHERE id = ANY(job_ids);
  DELETE FROM stages WHERE id = ANY(stage_ids);
  DELETE FROM request_payloads WHERE id = ANY(request_payload_ids);
  DELETE FROM requests WHERE id = ANY(request_ids);
  DELETE FROM commits WHERE id = ANY(commit_ids);
  DELETE FROM pull_requests WHERE id = ANY(pull_request_ids);
  DELETE FROM builds WHERE id = ANY(build_ids);
  DELETE FROM job_configs WHERE id = ANY(job_config_ids);
  DELETE FROM build_configs WHERE id = ANY(build_config_ids);
  DELETE FROM ssl_keys WHERE id = ANY(ssl_key_ids);
  DELETE FROM tags WHERE id = ANY(tag_ids);
  DELETE FROM request_configs WHERE id = ANY(request_config_ids);
END;
$$ LANGUAGE plpgsql;
