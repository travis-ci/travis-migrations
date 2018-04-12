class RenameHistoriesToRailsAdminHistories < ActiveRecord::Migration[4.2]
  def self.up
    remove_index :histories, name: :index_histories_on_item_and_table_and_month_and_year
    rename_table :histories, :rails_admin_histories
    add_index 'rails_admin_histories', ['item', 'table', 'month', 'year'], name: 'index_histories_on_item_and_table_and_month_and_year'

  end

  def self.down
    rename_table :rails_admin_histories, :histories
  end
end
