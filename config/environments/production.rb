Rails.application.configure do
  config.webpacker.check_yarn_integrity = false
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = {host: ENV['HOST']}
  config.action_controller.asset_host = ENV['ASSET_HOST']
  config.action_controller.perform_caching = true
  config.cache_store = :redis_store, {expires_in: 1.minute}
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.require_master_key = true
  config.force_ssl = true
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.active_record.dump_schema_after_migration = false
  config.log_level = :warn
  config.log_tags = [:request_id]
  config.log_formatter = ::Logger::Formatter.new

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  config.settings = {
    asset_root: '/assets',
    bootstrap: {
      start_date: Date.new(2017, 1, 1)
    }
  }.to_open_struct
end
