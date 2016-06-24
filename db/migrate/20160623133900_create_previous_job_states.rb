class CreatePreviousJobStates < ActiveRecord::Migration
  def change
    create_table :previous_job_states do |t|
      t.belongs_to :job
      t.datetime :set_at
      t.datetime :ended_at
      t.string :state
    end

    add_column :jobs, :previous_job_state_id, :bigint
  end
end
