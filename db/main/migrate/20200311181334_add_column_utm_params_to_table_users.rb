class AddColumnUtmParamsToTableUsers < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :users, :utm_params, :string, default: nil
  end
end
