require_relative 'logs_migration'
class CreateLogs < LogsMigration
  def self.up
    create_table :logs do |t|
      t.integer   :job_id
      t.text      :content
      t.integer   :removed_by

      t.datetime  :created_at
      t.datetime  :updated_at

      t.datetime  :aggregated_at
      t.datetime  :archived_at
      t.datetime  :purged_at
      t.datetime  :removed_at

      t.boolean  :archiving
      t.boolean  :archive_verified
    end

    add_index :logs, :archive_verified, name: 'index_logs_on_archive_verified'
    add_index :logs, :archived_at, name: 'index_logs_on_archived_at'
    add_index :logs, :job_id, name: 'index_logs_on_job_id'
  end

  def self.down
    drop_table :logs
  end
end
