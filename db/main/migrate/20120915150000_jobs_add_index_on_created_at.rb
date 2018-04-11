class JobsAddIndexOnCreatedAt < ActiveRecord::Migration[4.2]
  def change
    add_index 'jobs', 'created_at'
  end
end
