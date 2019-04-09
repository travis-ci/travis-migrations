class AddUniqueNumberColumnToBuilds < ActiveRecord::Migration[5.2]
  def change
    add_column :builds, :unique_number, :int
  end
end
