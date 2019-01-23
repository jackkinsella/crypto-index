caching_dev = Rails.root.join('tmp/caching-dev.txt').exist?
logging_dev = Rails.root.join('tmp/logging-dev.txt').exist?

Rails.application.configure do
  config.webpacker.check_yarn_integrity = true
  config.cache_classes = caching_dev
  config.eager_load = caching_dev
  config.consider_all_requests_local = true
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = {host: 'localhost:3000'}
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  config.logger = Logger.new(STDOUT)
  config.log_level = logging_dev ? :debug : :info

  if caching_dev
    config.action_controller.perform_caching = true
    config.cache_store = :memory_store, {expires_in: 15.seconds}
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{15.seconds}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  config.settings = {
    asset_root: '/assets',
    bootstrap: {
      start_date: 3.days.ago.to_date
    }
  }.to_open_struct
end
