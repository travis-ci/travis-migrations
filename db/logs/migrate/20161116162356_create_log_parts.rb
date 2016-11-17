class CreateLogParts < ActiveRecord::Migration
  def self.up
    create_table :log_parts, id: false do |t|
      t.integer   :id, primary_key: true, limit: 8 # bigint
      t.integer   :log_id, null: false
      t.text      :content
      t.integer   :number
      t.boolean   :final
      t.datetime  :created_at
    end

    add_index :log_parts, [:log_id, :number], name: 'index_log_parts_on_log_id_and_number'
    add_index :log_parts, :created_at
  end

  def self.down
    drop_table :log_parts
  end
end
