class UpdateSoftDelete < ActiveRecord::Migration[5.2]
  def up
    execute "create table deleted_request_yaml_configs (like request_yaml_configs)"
    execute File.read(Rails.root.join('db/main/sql/create_soft_delete_repo_data.sql'))
  end

  def down
  end
end
