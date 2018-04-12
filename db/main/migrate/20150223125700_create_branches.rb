class CreateBranches < ActiveRecord::Migration[4.2]
  def up
    create_table(:branches) do |t|
      t.integer :repository_id, null: false
      t.integer :last_build_id
      t.string  :name, null: false
      t.boolean :exists_on_github, default: true, null: false
      t.timestamps null: false
    end
    add_index(:branches, [:repository_id, :name], unique: true)
  end

  def down
    drop_table(:branches)
  end
end
