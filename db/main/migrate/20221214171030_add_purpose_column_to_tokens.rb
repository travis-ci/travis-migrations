# frozen_string_literal: true

class AddPurposeColumnToTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :tokens, :purpose, :integer, limit: 4, default: 0
  end
end
