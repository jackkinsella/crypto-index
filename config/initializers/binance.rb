if Rails.env.production?
  Rails.application.credentials.markets.binance.tap do |credentials|
    Binance::Api::Configuration.api_key = credentials.api_key
    Binance::Api::Configuration.secret_key = credentials.secret_key
  end
end
