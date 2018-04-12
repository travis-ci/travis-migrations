class RepositoriesAddPrivate < ActiveRecord::Migration[4.2]
  def change
    change_table :repositories do |t|
      t.boolean :private, :default => false
    end
  end
end
