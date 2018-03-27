class CreateRepoCountsPopulate < ActiveRecord::Migration
  def up
    execute sql
  end

  def down
    functions.each do |name|
      execute "DROP FUNCTION IF EXISTS #{name}()"
    end
  end

  def functions
    sql.split("\n").map { |l| l =~ /CREATE OR REPLACE FUNCTION (\w+)()/ && $1 }.compact
  end

  def sql
    File.read(File.expand_path('../../sql/repo_counts_populate.sql', __FILE__))
  end
end

