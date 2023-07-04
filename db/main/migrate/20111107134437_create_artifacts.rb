class CreateArtifacts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :artifacts do |t|
      t.text    :content
      t.integer :job_id
      t.string  :type

      t.timestamps null: false
    end

    # migrate_table :jobs, :to => :artifacts do |t|
    #  t.move :log, :to => :content
    #  t.set  :type, 'Artifact::Log'
    # end

    execute 'UPDATE artifacts SET job_id = id'
    execute "select setval('artifacts_id_seq', (select max(id) + 1 from artifacts));"

    add_index :artifacts, %i[type job_id]
  end

  def self.down
    change_table :jobs do |t|
      t.text :log
    rescue StandardError
      nil
    end

    # migrate_table :artifacts, :to => :jobs do |t|
    #  t.move :content, :to => :log rescue nil
    # end

    begin
      drop_table :artifacts
    rescue StandardError
      nil
    end
  end
end
