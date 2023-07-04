class CreateRepoCountsTriggers < ActiveRecord::Migration[4.2]
  FILES = %w[
    repo_counts_triggers.sql
    repo_counts_populate.sql
    repo_counts_aggregate.sql
  ]

  def up
    execute with_cutoff(sql)
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
    sql.split("\n").map { |l| l =~ /CREATE OR REPLACE FUNCTION (\w+)()/ && ::Regexp.last_match(1) }.compact
  end

  def triggers
    sql.split("\n").map { |l| l =~ /CREATE TRIGGER (\w+) .* ON (\w+)/ && [::Regexp.last_match(1), ::Regexp.last_match(2)] }.compact
  end

  def sql
    FILES.map { |file| read(file) }.join("\n")
  end

  def read(file)
    File.read(File.expand_path("../../sql/#{file}", __FILE__))
  end

  def with_cutoff(sql)
    return sql unless production?

    sql.gsub('2018-01-01 00:00:00', Time.now.utc.to_s.gsub(' UTC', ''))
  end

  def production?
    ENV['RAILS_ENV'] == 'production'
  end
end
