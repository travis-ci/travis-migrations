class SettingsCreateTables < ActiveRecord::Migration
  def change
    create_table :env_vars do |t|
      t.belongs_to :owner, polymorphic: true
      t.string :name
      t.string :value
      t.boolean :public, default: false
    end

    create_table :ssh_keys do |t|
      t.belongs_to :owner, polymorphic: true
      t.string :key
      t.string :description
    end

    create_table :settings do |t|
      # owner_groups use uuids, so this needs to be a string
      t.string :owner_type
      t.string :owner_id
      t.string :key
      t.text :value # ok to use a blob here?
      t.datetime :expires_at
      t.text :comment
    end

    # TODO add indices
  end
end
