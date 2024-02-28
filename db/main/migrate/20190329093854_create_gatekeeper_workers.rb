# frozen_string_literal: true

class CreateGatekeeperWorkers < ActiveRecord::Migration[5.2]
  def up
    create_table :gatekeeper_workers do |t|
    end

    execute 'INSERT INTO gatekeeper_workers(id) SELECT generate_series(1,200) as id;'
  end

  def down
    drop_table :gatekeeper_workers
  end
end
