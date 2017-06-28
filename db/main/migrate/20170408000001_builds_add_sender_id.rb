class BuildsAddSenderId < ActiveRecord::Migration
  def change
    change_table :builds do |t|
      t.belongs_to :sender, polymorphic: true
    end
  end
end
