class CreateJobConfigsGpu < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute <<~sql
      CREATE MATERIALIZED VIEW job_configs_gpu AS
      SELECT id FROM job_configs WHERE
        is_json((config ->> 'resources')::text) AND
        ((config ->> 'resources')::jsonb ->> 'gpu') IS NOT NULL;
    sql
  end

  def down
    execute <<~sql
      DROP MATERIALIZED VIEW job_configs_gpu
    sql
  end
end


