#!/usr/bin/env ruby

path_to_structure = ARGV[0] || 'db/main/structure.sql'
path = File.expand_path("../../#{path_to_structure}", __FILE__)
structure = File.read(path)
if structure =~ /AS integer/
  STDERR.puts <<-MESSAGE
\033[0;31mStructure dump was generated using a PostgreSQL 10 or later.
It's incompatible with 9.6 which we use in production. Please revert the
structure.sql file changes and regenerate the file using earlier PostgreSQL
version.\033[0m
MESSAGE
  exit 1
end
