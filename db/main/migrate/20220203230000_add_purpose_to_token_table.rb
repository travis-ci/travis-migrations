class AddPurposeToTokenTable < ActiveRecord::Migration
  def self.up
    add_column :tokens , :purpose , :string
  end

  def self.down
    remove_column :tokens, :purpose
  end
end
