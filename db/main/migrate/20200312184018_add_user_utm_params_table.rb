# frozen_string_literal: true

class AddUserUtmParamsTable < ActiveRecord::Migration[5.2]
  def up
    create_table :user_utm_params do |t|
      t.jsonb :utm_data
      t.belongs_to :user
      t.timestamps
    end
  end

  def down
    drop_table :user_utm_params
  end
end
