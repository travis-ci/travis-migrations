class CreateUserBetaFeatures < ActiveRecord::Migration[4.2]
  def change
    create_table :user_beta_features do |t|
      t.references :user
      t.references :beta_feature
      t.boolean :enabled
      t.timestamp :last_deactivated_at
      t.timestamp :last_activated_at
    end

    add_index :user_beta_features, %i[user_id beta_feature_id]
  end
end
