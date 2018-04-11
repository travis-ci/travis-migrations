class ArtifactsAddAggregatedAt < ActiveRecord::Migration[4.2]
  def change
    add_column :artifacts, :aggregated_at, :datetime
  end
end

