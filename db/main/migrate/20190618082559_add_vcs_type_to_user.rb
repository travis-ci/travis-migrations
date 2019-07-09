class AddVcsTypeToUser < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    ActiveRecord::Base.transaction do
      add_column :users, :vcs_type, :string
    end

    last_id = select_value('SELECT id FROM users ORDER BY id DESC LIMIT 1') || 0
    batch_size = 5000
    (0..last_id).step(batch_size).each do |from_id|
      to_id = from_id + batch_size

      ActiveRecord::Base.transaction do
        execute %Q[UPDATE users SET vcs_type = 'GithubUser' WHERE id BETWEEN #{from_id} AND #{to_id}]
      end
    end
  rescue => e
    down
    raise e
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :users, :vcs_type
    end
  end
end
