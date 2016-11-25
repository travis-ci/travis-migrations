class CreateFeaturesTable < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.string :name
      t.string :feedback_url
      t.references :owner, polymorphic: true
      t.boolean :public
      t.boolean :modifiable
      t.boolean :active
      t.timestamp :expires_on
      t.timestamps
    end
    
    add_index :features, [:name, :owner_id]
  end
end
