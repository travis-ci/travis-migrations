class AddEducationFieldToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :education, :boolean
  end
end
