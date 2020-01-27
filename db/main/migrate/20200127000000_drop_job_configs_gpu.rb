class DropJobConfigsGpu < ActiveRecord::Migration[5.2]
  def up
    execute <<~sql
      DROP MATERIALIZED VIEW job_configs_gpu
    sql
  end

  def down
    execute <<~sql
      CREATE MATERIALIZED VIEW job_configs_gpu AS
      SELECT id FROM job_configs WHERE
        is_json((config ->> 'resources')::text) AND
        ((config ->> 'resources')::jsonb ->> 'gpu') IS NOT NULL;
    sql
  end
end
