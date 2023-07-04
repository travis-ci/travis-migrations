# frozen_string_literal: true

class DropArtifacts < ActiveRecord::Migration[4.2]
  def change
    drop_table :artifacts_backup
    drop_table :artifact_parts_backup
  end
end
