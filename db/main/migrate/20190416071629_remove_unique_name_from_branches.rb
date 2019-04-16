class RemoveUniqueNameFromBranches < ActiveRecord::Migration[5.2]
  self.disable_ddl_transaction!

  def up
    execute "drop index concurrently index_branches_repository_id_unique_name;"
    execute File.read(Rails.root.join('db/main/sql/triggers/drop_set_unique_name.sql'))
    remove_column :branches, :unique_name
  end

  def down
    add_column :branches, :unique_name, :text
    execute File.read(Rails.root.join('db/main/sql/triggers/create_set_unique_name.sql'))
    execute "create unique index concurrently index_branches_repository_id_unique_name on branches(repository_id, unique_name);"
  end
end
