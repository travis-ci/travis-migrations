# frozen_string_literal: true

class CacheFullNameInWorkers < ActiveRecord::Migration[4.2]
  def change
    add_column :workers, :full_name, :string
    add_index :workers, :full_name
  end
end
