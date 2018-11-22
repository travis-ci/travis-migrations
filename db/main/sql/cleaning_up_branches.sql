BEGIN;
explain analyze WITH duplicated_branches_names AS (
    SELECT repository_id, name FROM (
      SELECT  branches.repository_id AS repository_id,
              branches.name AS name,
              ROW_NUMBER() OVER(PARTITION BY repository_id, name ORDER BY id asc) AS row
      FROM branches
    ) dups
    WHERE dups.row = 2 -- we just need one row that's a duplicate
),
ranked_branches AS (
  SELECT branches.*,
    ROW_NUMBER() OVER(PARTITION BY repository_id, name ORDER BY last_build_id DESC NULLS LAST) AS row
  FROM branches
  WHERE (repository_id, name) IN (SELECT repository_id, name FROM duplicated_branches_names)
),
updated_crons AS (
  UPDATE crons SET branch_id = (SELECT id FROM ranked_branches rb WHERE rb.repository_id = ranked_branches.repository_id AND rb.name = ranked_branches.name AND rb.row = 1)
  FROM ranked_branches
  WHERE crons.branch_id = ranked_branches.id AND ranked_branches.row > 1
  RETURNING crons.id
),
updated_builds AS (
  UPDATE builds SET branch_id = (SELECT id FROM ranked_branches rb WHERE rb.repository_id = ranked_branches.repository_id AND rb.name = ranked_branches.name AND rb.row = 1)
  FROM ranked_branches
  WHERE builds.branch_id = ranked_branches.id AND ranked_branches.row > 1
  RETURNING builds.id
),
updated_commits AS (
  UPDATE commits SET branch_id = (SELECT id FROM ranked_branches rb WHERE rb.repository_id = ranked_branches.repository_id AND rb.name = ranked_branches.name AND rb.row = 1)
  FROM ranked_branches
  WHERE commits.branch_id = ranked_branches.id AND ranked_branches.row > 1
  RETURNING commits.id
),
updated_requests AS (
  UPDATE requests SET branch_id = (SELECT id FROM ranked_branches rb WHERE rb.repository_id = ranked_branches.repository_id AND rb.name = ranked_branches.name AND rb.row = 1)
  FROM ranked_branches
  WHERE requests.branch_id = ranked_branches.id AND ranked_branches.row > 1
  RETURNING requests.id
),
deleted_branches AS (
  DELETE FROM branches
  WHERE id IN (SELECT id FROM ranked_branches WHERE row > 1)
  RETURNING branches.id
)
SELECT id FROM deleted_branches;
