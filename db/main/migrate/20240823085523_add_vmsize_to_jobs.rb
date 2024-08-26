class AddVmsizeToJobs < ActiveRecord::Migration[7.0]
  def change
    add_column :jobs, :vm_size, :string
    add_column :deleted_jobs, :vm_size, :string
  end
end
