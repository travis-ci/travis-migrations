class AddColumnPurposeToTableToken < ActiveRecord::Migration[5.2]
  def up
    add_column :tokens, :purpose, :string, default: nil
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :jobs, :tokens
    end
  end  
end
