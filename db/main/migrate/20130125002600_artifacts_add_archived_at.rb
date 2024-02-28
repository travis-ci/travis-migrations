# frozen_string_literal: true

class ArtifactsAddArchivedAt < ActiveRecord::Migration[4.2]
  def change
    add_column :artifacts, :archived_at, :datetime
    add_index :artifacts, :archived_at
  end
end
