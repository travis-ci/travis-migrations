# frozen_string_literal: true

class RenameArtifacts < ActiveRecord::Migration[4.2]
  def change
    rename_table :artifacts, :artifacts_backup
    rename_table :artifact_parts, :artifact_parts_backup
  end
end
