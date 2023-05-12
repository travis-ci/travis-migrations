class RolifyCreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table(:roles) do |t|
      t.string :name
      t.string :description
      t.string :object_type
      t.references :resource, :polymorphic => true

      t.timestamps
    end

    create_table(:role_names) do |t|
      t.string :name
      t.string :description
      t.string :role_type
    end

    create_table(:users_roles, :id => false) do |t|
      t.references :user
      t.references :role
    end
    
    add_index(:roles, :name)
    add_index(:role_names, :name)
    add_index(:roles, [ :name, :resource_type, :resource_id ])
    add_index(:users_roles, [ :user_id, :role_id ])
  end
end
