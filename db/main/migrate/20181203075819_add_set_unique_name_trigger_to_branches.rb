class AddSetUniqueNameTriggerToBranches < ActiveRecord::Migration[5.2]
  def up
    add_column :branches, :unique_name, :text
    execute File.read(Rails.root.join('db/main/sql/triggers/create_set_unique_name.sql'))
  end

  def down
    execute File.read(Rails.root.join('db/main/sql/triggers/drop_set_unique_name.sql'))
    remove_column :branches, :unique_name
  end
end
