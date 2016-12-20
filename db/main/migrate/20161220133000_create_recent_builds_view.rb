class CreateRecentBuildsView < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE MATERIALIZED VIEW recent_builds AS
        SELECT
          id,
          repository_id,
          started_at,
          finished_at,
          created_at,
          updated_at,
          config,
          commit_id,
          request_id,
          state,
          duration,
          owner_id,
          owner_type,
          event_type,
          previous_state,
          pull_request_title,
          pull_request_number,
          branch, canceled_at,
          cached_matrix_ids,
          received_at,
          private,
          number::integer as "number"
        FROM
          builds
        WHERE
          created_at > CURRENT_DATE - INTERVAL '1 day'
    SQL
  end
end
