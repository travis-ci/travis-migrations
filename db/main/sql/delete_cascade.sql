DROP FUNCTION IF EXISTS delete_repository_cascade(text, text, bigint);
CREATE FUNCTION delete_repository_cascade(_owner_name text, _name text, rid bigint) RETURNS void AS $$
DECLARE
  _id bigint;
BEGIN
  SELECT id INTO _id FROM repositories WHERE repositories.owner_name = _owner_name AND repositories.name = _name AND repositories.id = rid;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'repository not found';
  ELSE
    UPDATE branches SET last_build_id = NULL WHERE repository_id = rid;
    UPDATE repositories SET last_build_id = NULL, current_build_id = NULL WHERE id = rid;
    DELETE FROM stages WHERE build_id IN (SELECT id FROM builds WHERE repository_id = rid);
    DELETE FROM jobs WHERE repository_id = rid;
    DELETE FROM builds WHERE repository_id = rid;
    DELETE FROM requests WHERE repository_id = rid;
    DELETE FROM commits WHERE repository_id = rid;
    DELETE FROM pull_requests WHERE repository_id = rid;
    DELETE FROM crons WHERE branch_id IN (SELECT id FROM branches WHERE repository_id = rid);
    DELETE FROM job_configs WHERE repository_id = rid;
    DELETE FROM build_configs WHERE repository_id = rid;
    DELETE FROM ssl_keys WHERE repository_id = rid;
    DELETE FROM branches WHERE repository_id= rid;
    DELETE FROM tags WHERE repository_id = rid;
    DELETE FROM repositories WHERE id = rid;
  END IF;
END;
$$ LANGUAGE plpgsql;
