# frozen_string_literal: true

class AddAnnotationProviderIdToAnnotations < ActiveRecord::Migration[4.2]
  def change
    add_column(:annotations, :annotation_provider_id, :integer, null: false)
  end
end
