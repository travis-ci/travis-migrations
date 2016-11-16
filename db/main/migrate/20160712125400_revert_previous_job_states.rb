class RevertPreviousJobStates < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP TRIGGER IF EXISTS save_state_change_on_update on jobs;
      DROP TRIGGER IF EXISTS save_state_change_on_insert on jobs;
      DROP FUNCTION IF EXISTS save_state_change();
    SQL

    remove_column :jobs, :previous_job_state_id
    drop_table :previous_job_states
  end

  def down
    # I don't think that we need this
  end
end
