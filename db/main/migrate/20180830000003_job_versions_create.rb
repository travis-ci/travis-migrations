# frozen_string_literal: true

class JobVersionsCreate < ActiveRecord::Migration[4.2]
  def change
    create_table :job_versions do |t|
      t.integer  :job_id
      t.integer  :number
      t.string   :state
      t.datetime :created_at
      t.datetime :queued_at
      t.datetime :received_at
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :restarted_at
    end
  end
end
