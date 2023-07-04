# frozen_string_literal: true

class DropJobConfigsGpu < ActiveRecord::Migration[5.2]
  def up
    execute <<~SQL
      DROP MATERIALIZED VIEW job_configs_gpu
    SQL
  end

  def down
    execute <<~SQL
      CREATE MATERIALIZED VIEW job_configs_gpu AS
      SELECT id FROM job_configs WHERE
        is_json((config ->> 'resources')::text) AND
        ((config ->> 'resources')::jsonb ->> 'gpu') IS NOT NULL;
    SQL
  end
end
