class ArtifactPartsAddIndexOnArtifactId < ActiveRecord::Migration[4.2]
  def change
    add_index :artifact_parts, :artifact_id
  end
end

