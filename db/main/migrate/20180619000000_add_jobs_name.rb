class AddJobsName < ActiveRecord::Migration[4.2]
  def change
    add_column :jobs, :name, :string
  end
end
