class CreateBuildBackupsTable < ActiveRecord::Migration[4.2]
  def self.up
    create_table :build_backups do |t|
      t.belongs_to :repository
      t.string     :file_name
      t.timestamp  :created_at
    end
  end

  def self.down
    drop_table :build_backups
  end
end
