return if Rails.env.production?

module Binance
  module Api
    class Account
      class << self
        def trades!(symbol: nil)
          Order.history.select { |order|
            symbol.nil? || order[:symbol] == symbol
          }.values
        end
      end
    end
  end
end
