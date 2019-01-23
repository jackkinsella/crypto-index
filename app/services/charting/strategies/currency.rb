module Charting
  module Strategies
    class Currency
      PRICE_USD_DIGITS = 5

      def initialize(currency)
        @currency = currency
      end

      def compile(timestamps)
        valuations_for(currency, timestamps).map do |valuation|
          [
            valuation.timestamp.to_i * 1_000,
            valuation.price_usd.round(PRICE_USD_DIGITS)
          ]
        end
      end

      private

      attr_reader :currency

      def valuations_for(currency, timestamps)
        currency.valuations.asc.at(timestamps).select(:timestamp, :price_usd)
      end
    end
  end
end
