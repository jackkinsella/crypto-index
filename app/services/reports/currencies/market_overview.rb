module Reports
  module Currencies
    class MarketOverview < ApplicationAction
      include Requests

      HOST = 'https://coinmarketcap.com'.freeze

      def initialize(name:)
        @name =
          Sources::CoinMarketCap::NAME_MAPPINGS[name.to_sym] || name.to_sym
      end

      def execute!
        html = Nokogiri::HTML(read_page(endpoint))
        html.search('table#markets-table tr').drop(1).map do |row|
          _, exchange, pair, volume24h, price, volume_percent, recency =
            row.text.strip.split(/[\n ]+/)

          {
            exchange: exchange,
            pair: pair,
            volume24h: volume24h.extract_d,
            price: price.extract_d,
            volume_percent: volume_percent.extract_d,
            data_recent?: recency == 'Recently',
            markings_by_coin_market_cap: markings(row),
            tradeable_on_supported_exchanges?:
              supported_exchanges.include?(exchange)
          }
        end
      end

      private

      attr_reader :name

      def supported_exchanges
        ['Binance']
      end

      def markings(row)
        {
          outlier: outlier?(row),
          no_trading_fees: no_trading_fees?(row),
          price_excluded: price_excluded?(row)
        }
      end

      def outlier?(row)
        exactly_three_stars = /\*{3}/
        row.text.match?(exactly_three_stars)
      end

      def no_trading_fees?(row)
        exactly_two_stars = /[^\*]\*{2}[^\*]/
        row.text.match?(exactly_two_stars)
      end

      def price_excluded?(row)
        one_star_only = /[^\*]\*[^\*]/
        row.text.match?(one_star_only)
      end

      def endpoint
        "#{HOST}/currencies/#{name}/#markets"
      end
    end
  end
end
