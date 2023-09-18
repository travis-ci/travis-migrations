# frozen_string_literal: true

class RequestsAddBranchIdAndTagId < ActiveRecord::Migration[4.2]
  def change
    change_table :requests do |t|
      t.belongs_to :branch
      t.belongs_to :tag
    end
  end
end
