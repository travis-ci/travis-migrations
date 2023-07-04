class CreateJobConfigsGpu < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute <<~SQL
      CREATE MATERIALIZED VIEW job_configs_gpu AS
      SELECT id FROM job_configs WHERE
        is_json((config ->> 'resources')::text) AND
        ((config ->> 'resources')::jsonb ->> 'gpu') IS NOT NULL;
    SQL
  end

  def down
    execute <<~SQL
      DROP MATERIALIZED VIEW job_configs_gpu
    SQL
  end
end
