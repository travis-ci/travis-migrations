class ExcludedFromCleanup < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :excluded_from_cleanup, :boolean, default: false
    add_column :organizations, :excluded_from_cleanup, :boolean, default: false
  end
end
