module Charting
  module Strategies
    class Portfolio
      def initialize(portfolio)
        @portfolio = portfolio
      end

      def compile(timestamps)
        compositions_for(portfolio, timestamps).map do |composition|
          [
            composition.timestamp.to_i * 1_000,
            composition.value_usd.round(2)
          ]
        end
      end

      private

      attr_reader :portfolio

      def compositions_for(portfolio, timestamps)
        portfolio.compositions.asc.at(timestamps).select(:timestamp, :value_usd)
      end
    end
  end
end
