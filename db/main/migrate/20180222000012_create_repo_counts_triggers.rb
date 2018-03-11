class CreateRepoCountsTriggers < ActiveRecord::Migration
  def up
    execute sql
  end

  def down
    triggers.each do |name, table|
      execute "DROP TRIGGER IF EXISTS #{name} ON #{table}"
    end

    functions.each do |name|
      execute "DROP FUNCTION IF EXISTS #{name}()"
    end
  end

  def functions
    sql.split("\n").map { |l| l =~ /CREATE OR REPLACE FUNCTION (\w+)()/ && $1 }.compact
  end

  def triggers
    sql.split("\n").map { |l| l =~ /CREATE TRIGGER (\w+) .* ON (\w+)/ && [$1, $2] }.compact
  end

  def sql
    File.read(File.expand_path('../../sql/repo_counts_triggers.sql', __FILE__))
  end
end
