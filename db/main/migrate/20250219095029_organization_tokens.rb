class OrganizationTokens < ActiveRecord::Migration[7.0]
  def up
    create_table(:organization_tokens) do |t|
      t.references :organization, null: false
      t.string :token
      t.timestamps
    end

    create_table(:organization_token_permissions) do |t|
      t.references :organization_token, null: false
      t.string :permission, null: false
      t.timestamps
    end
  end

  def down
    drop_table(:organization_token_permissions)
    drop_table(:organization_tokens)
  end
end
