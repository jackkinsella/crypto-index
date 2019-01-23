return if Rails.env.production?

module Binance
  module Api
    class Error < StandardError; end
  end
end
