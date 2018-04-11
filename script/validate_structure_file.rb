#!/usr/bin/env ruby

structure = File.read(File.expand_path('../../db/main/structure.sql', __FILE__))
if structure =~ /AS integer/
  STDERR.puts <<-MESSAGE
\033[0;31mStructure dump was generated using a PostgreSQL 10 or later.
It's incompatible with 9.6 which we use in production. Please revert the
structure.sql file changes and regenerate the file using earlier PostgreSQL
version.\033[0m
MESSAGE
  exit 1
end
