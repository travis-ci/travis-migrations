Rails.application.configure do
  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
