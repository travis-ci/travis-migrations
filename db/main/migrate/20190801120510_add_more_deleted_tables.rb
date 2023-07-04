class AddMoreDeletedTables < ActiveRecord::Migration[5.2]
  def up
    execute 'create table if not exists deleted_request_raw_configs (like request_raw_configs)'
    execute 'create table if not exists deleted_request_raw_configurations (like request_raw_configurations)'

    execute File.read(Rails.root.join('db/main/sql/create_soft_delete_repo_data.sql'))
  end

  def down
    execute 'drop table deleted_request_raw_configs'
    execute 'drop table deleted_request_raw_configurations'
  end
end
