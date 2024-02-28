# frozen_string_literal: true

class AddUniqueNameColumnToBranches < ActiveRecord::Migration[5.2]
  def change
    add_column :branches, :unique_name, :text
  end
end
