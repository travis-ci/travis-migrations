# frozen_string_literal: true

class CreateAuditsTable < ActiveRecord::Migration[5.2]
  def self.up
    create_table :audits do |t|
      t.integer  :owner_id
      t.string   :owner_type
      t.datetime :created_at
      t.string   :change_source
      t.json     :source_changes
      t.integer  :source_id
      t.string   :source_type
    end
  end

  def self.down
    drop_table :audits
  end
end
