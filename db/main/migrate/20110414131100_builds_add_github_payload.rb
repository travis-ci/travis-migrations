class BuildsAddGithubPayload < ActiveRecord::Migration[4.2]
  def self.up
    change_table :builds do |t|
      t.text :github_payload
    end
  end

  def self.down
    change_table :builds do |t|
      t.remove :github_payload
    end
  end
end
