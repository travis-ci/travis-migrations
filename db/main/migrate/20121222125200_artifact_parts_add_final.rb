# frozen_string_literal: true

class ArtifactPartsAddFinal < ActiveRecord::Migration[4.2]
  def change
    add_column :artifact_parts, :final, :boolean
    add_column :artifact_parts, :created_at, :timestamp
  end
end
