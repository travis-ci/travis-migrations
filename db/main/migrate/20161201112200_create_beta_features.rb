class CreateBetaFeatures < ActiveRecord::Migration
  def change
    create_table :beta_features do |t|
      t.string :name
      t.text :description
      t.string :feedback_url
      t.boolean :staff_only
      t.boolean :default_enabled
      t.timestamps
    end
  end
end
