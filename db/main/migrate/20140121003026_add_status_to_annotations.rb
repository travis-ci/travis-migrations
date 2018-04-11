class AddStatusToAnnotations < ActiveRecord::Migration[4.2]
  def change
    add_column :annotations, :status, :string
  end
end
