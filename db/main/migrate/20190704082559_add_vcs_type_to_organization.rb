class AddVcsTypeToOrganization < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    ActiveRecord::Base.transaction do
      add_column :organizations, :vcs_type, :string, default: nil
      execute(%(ALTER TABLE organizations ALTER COLUMN vcs_type SET DEFAULT 'GithubOrganization'))
    end

    last_id = select_value('SELECT id FROM organizations ORDER BY id DESC LIMIT 1') || 0
    batch_size = 5000
    (0..last_id).step(batch_size).each do |from_id|
      to_id = from_id + batch_size

      ActiveRecord::Base.transaction do
        execute %(UPDATE organizations SET vcs_type = 'GithubOrganization' WHERE id BETWEEN #{from_id} AND #{to_id})
      end
    end
  rescue StandardError => e
    down
    raise e
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :organizations, :vcs_type
    end
  end
end
