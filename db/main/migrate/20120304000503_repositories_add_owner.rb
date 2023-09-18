# frozen_string_literal: true

class RepositoriesAddOwner < ActiveRecord::Migration[4.2]
  def change
    change_table :repositories do |t|
      t.references :owner, polymorphic: true
    end
  end
end
