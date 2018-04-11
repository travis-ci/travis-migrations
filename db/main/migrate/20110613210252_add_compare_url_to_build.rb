class AddCompareUrlToBuild < ActiveRecord::Migration[4.2]
  def self.up
    add_column :builds, :compare_url, :string
  end

  def self.down
    remove_column :builds, :compare_url
  end
end
