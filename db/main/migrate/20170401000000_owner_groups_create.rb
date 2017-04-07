class OwnerGroupsCreate < ActiveRecord::Migration
  def change
    create_table :owner_groups do |t|
      t.string :uuid
      t.belongs_to :owner, polymorphic: true
      t.timestamps
    end
  end
end
