class AddComIdAndOrgId < ActiveRecord::Migration
  def change
    add_column :branches, :org_id, :integer
    add_column :builds, :org_id, :integer
    add_column :commits, :org_id, :integer
    add_column :crons, :org_id, :integer
    add_column :jobs, :org_id, :integer
    add_column :organizations, :org_id, :integer
    add_column :permissions, :org_id, :integer
    add_column :pull_requests, :org_id, :integer
    add_column :repositories, :org_id, :integer
    add_column :requests, :org_id, :integer
    add_column :ssl_keys, :org_id, :integer
    add_column :stages, :org_id, :integer
    add_column :tags, :org_id, :integer
    add_column :users, :org_id, :integer

    add_column :branches, :com_id, :integer
    add_column :builds, :com_id, :integer
    add_column :commits, :com_id, :integer
    add_column :crons, :com_id, :integer
    add_column :jobs, :com_id, :integer
    add_column :organizations, :com_id, :integer
    add_column :permissions, :com_id, :integer
    add_column :pull_requests, :com_id, :integer
    add_column :repositories, :com_id, :integer
    add_column :requests, :com_id, :integer
    add_column :ssl_keys, :com_id, :integer
    add_column :stages, :com_id, :integer
    add_column :tags, :com_id, :integer
    add_column :users, :com_id, :integer
  end
end
