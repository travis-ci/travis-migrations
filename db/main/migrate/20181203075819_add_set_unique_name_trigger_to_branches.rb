class AddSetUniqueNameTriggerToBranches < ActiveRecord::Migration[5.2]
  def up
    add_column :branches, :unique_name, :text
    execute File.read(Rails.root.join('db/main/sql/triggers/create_set_unique_name.sql'))
  end

  def down
    drop_column :branches, :unique_name
    execute File.read(Rails.root.join('db/main/sql/triggers/drop_set_unique_name.sql'))
  end
end
