require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false

  # Static files are served by Puma itself inside the container (Nginx may cache them in front)
  config.public_file_server.enabled = true
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }


  # HTTPS: enabled only when the app is published behind a TLS-terminating proxy (RAILS_FORCE_SSL=true)
  force_ssl = ENV.fetch("RAILS_FORCE_SSL", "true") == "true"
  config.assume_ssl = force_ssl
  config.force_ssl  = force_ssl

  # Logging to STDOUT so that `docker compose logs` / journalctl show everything
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_tags = [:request_id]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false

  # No external cache / queue backends are required for this application
  config.cache_store = :memory_store, { size: 32.megabytes }
  config.active_job.queue_adapter = :async

  config.action_controller.perform_caching = true
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST", "localhost") }

  config.i18n.fallbacks = true
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [:id]

  # Allow any host header (the app sits behind Nginx / Docker and has no fixed domain)
  config.hosts.clear
end
