# frozen_string_literal: true

class AddVcsSlugToRepository < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_column :repositories, :vcs_slug, :string, default: nil
  end

  def down
    ActiveRecord::Base.transaction do
      remove_column :repositories, :vcs_slug
    end
  end
end
