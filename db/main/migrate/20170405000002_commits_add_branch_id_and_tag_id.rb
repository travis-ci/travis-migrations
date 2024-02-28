# frozen_string_literal: true

class CommitsAddBranchIdAndTagId < ActiveRecord::Migration[4.2]
  def change
    change_table :commits do |t|
      t.belongs_to :branch
      t.belongs_to :tag
    end
  end
end
