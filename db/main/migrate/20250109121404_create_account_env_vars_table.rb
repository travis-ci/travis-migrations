class CreateAccountEnvVarsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :account_env_vars do |t|
      t.integer  :owner_id
      t.string   :owner_type
      t.string   :name
      t.string   :value
      t.boolean  :public
      t.timestamp :created_at
      t.timestamp :updated_at
    end

    add_index :account_env_vars, :owner_id
  end

  def self.down
    drop_table :account_env_vars
  end
end
