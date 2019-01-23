unless Rails.env.production?
  Sidekiq.default_worker_options = {
    backtrace: true
  }

  Sidekiq.configure_client do |config|
    config.redis = {
      namespace: 'crypto_index_home'
    }
  end

  Sidekiq.configure_server do |config|
    config.redis = {
      namespace: 'crypto_index_home'
    }
  end
end

unless Rails.env.development?
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(
      Digest::SHA256.hexdigest(username),
      Digest::SHA256.hexdigest(Rails.application.credentials.admin.name)
    ) &
    ActiveSupport::SecurityUtils.secure_compare(
      Digest::SHA256.hexdigest(password),
      Digest::SHA256.hexdigest(Rails.application.credentials.admin.password)
    )
  end
end
