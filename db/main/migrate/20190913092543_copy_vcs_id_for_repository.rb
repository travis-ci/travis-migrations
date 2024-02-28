# frozen_string_literal: true

class CopyVcsIdForRepository < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    last_id = select_value('SELECT id FROM repositories ORDER BY id DESC LIMIT 1') || 0
    batch_size = 5000
    (0..last_id).step(batch_size).each do |from_id|
      to_id = from_id + batch_size

      ActiveRecord::Base.transaction do
        execute(%(UPDATE "repositories" SET vcs_id = github_id WHERE id BETWEEN #{from_id} AND #{to_id}))
      end
    end
  end

  def down; end
end
