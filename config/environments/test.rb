Rails.application.configure do
  config.cache_classes = true
  config.cache_store = :memory_store
  config.eager_load = ENV['COVERAGE'] || false
  config.public_file_server.enabled = true
  config.consider_all_requests_local = true
  config.action_mailer.delivery_method = :test
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = {host: 'localhost:3000'}
  config.action_controller.perform_caching = false
  config.cache_store = :null_store
  config.action_dispatch.show_exceptions = false
  config.action_controller.allow_forgery_protection = false
  config.active_support.deprecation = :stderr

  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  config.settings = {
    asset_root: '/assets-test'
  }.to_open_struct
end
