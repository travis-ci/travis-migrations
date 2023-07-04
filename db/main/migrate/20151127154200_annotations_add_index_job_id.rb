# frozen_string_literal: true

class AnnotationsAddIndexJobId < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def up
    execute 'CREATE INDEX CONCURRENTLY index_annotations_on_job_id ON annotations (job_id)'
  end

  def down
    execute 'DROP INDEX CONCURRENTLY index_annotations_on_job_id'
  end
end
