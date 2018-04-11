class OrganizationsCreate < ActiveRecord::Migration[4.2]
  def up
    create_table :organizations do |t|
      t.string   :name
      t.string   :login
      t.integer  :github_id
      t.timestamps null: false
    end
  end

  def down
    drop_table :organizations
  end
end
