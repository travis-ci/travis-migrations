class ArtifactPartsRemoveIndexOnArtifactId < ActiveRecord::Migration[4.2]
  def change
    remove_index :artifact_parts, :artifact_id
  end
end

