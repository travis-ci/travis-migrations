class JobConfigsIndexConfigResourcesGpu < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute <<~sql
      CREATE OR REPLACE FUNCTION is_json(text) RETURNS boolean LANGUAGE plpgsql immutable AS $$
        BEGIN
          perform $1::json;
          return true;
        EXCEPTION WHEN invalid_text_representation THEN
          return false;
        END
      $$;
    sql

    execute <<~sql
      CREATE INDEX CONCURRENTLY index_job_configs_on_config_resources_gpu ON job_configs (((config ->> 'resources')::jsonb ->> 'gpu')) WHERE is_json((config ->> 'resources')::text) AND ((config ->> 'resources')::jsonb ->> 'gpu') IS NOT NULL;
    sql
  end

  def down
    execute <<~sql
      DROP INDEX index_job_configs_on_config_resources_gpu;
      DROP FUNCTION is_json(text);
    sql
  end
end
