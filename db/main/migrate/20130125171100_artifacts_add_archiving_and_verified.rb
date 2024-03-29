# frozen_string_literal: true

class ArtifactsAddArchivingAndVerified < ActiveRecord::Migration[4.2]
  def change
    add_column :artifacts, :archiving, :boolean
    add_column :artifacts, :archive_verified, :boolean

    add_index :artifacts, :archiving
    add_index :artifacts, :archive_verified
  end
end
