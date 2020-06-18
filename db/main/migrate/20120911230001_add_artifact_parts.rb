class AddArtifactParts < ActiveRecord::Migration[4.2]
  def change
    create_table :artifact_parts do |t|
      t.references :artifact
      t.string  :content
      t.integer :number
    end

    add_index :artifact_parts, [:artifact_id, :number]
  end
end
