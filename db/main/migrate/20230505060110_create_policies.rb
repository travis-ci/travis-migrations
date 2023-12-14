class CreatePolicies < ActiveRecord::Migration[5.2]
  def change
    create_table :policy_permissions do |t|
      t.string :name
      t.string :description
      t.string :type

      t.timestamps
    end

    create_table(:role_permissions, :id => false) do |t|
      t.references :role_name
      t.references :policy_permission
    end

    add_index(:policy_permissions, :name)
    add_index(:role_permissions, [:role_name_id, :policy_permission_id])
  end
end
