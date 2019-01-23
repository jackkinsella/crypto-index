module Reports
  module Currencies
    class MaximumMarketCap < ApplicationAction
      include Requests

      HOST = 'https://coinmarketcap.com'.freeze

      def initialize(date: Date.today, number: 30)
        @date = date
        @number = number
      end

      def execute!
        extract_data(read_page(endpoint))
      end

      private

      attr_reader :date, :number

      def extract_data(response)
        html = Nokogiri::HTML(response)
        rows = html.search(currency_rows_selector(date))

        rows.drop(1).first(number).map { |row|
          symbol, title = row.at('.currency-name').text.strip.split("\n")
          market_cap = row.at('.market-cap').text.extract_d
          url = row.at('.currency-symbol a').attr(:href)
          name = url.split('/').last

          {
            title: title,
            name: name,
            date: date,
            symbol: symbol,
            market_cap: market_cap,
            coin_market_cap_url: "#{HOST}#{url}",
            already_seen?: already_seen?(symbol),
            rejected?: rejected?(symbol),
            tradeable_on_supported_exchanges?:
              tradeable_on_supported_exchanges?(name)
          }
        }
      end

      def available_historical_snapshot_dates
        earliest_date = Date.parse('April 28, 2013')

        Date.partition(
          earliest_date, Date.today, resolution: 1.week
        )
      end

      def currency_rows_selector(date)
        if date.today?
          '#currencies tr'
        else
          '#currencies-all tr'
        end
      end

      def endpoint
        if date.today?
          today_endpoint
        else
          nearest_possible_date = available_historical_snapshot_dates.
            find { |snapshot_date| snapshot_date >= date }
          historical_endpoint(nearest_possible_date)
        end
      end

      def today_endpoint
        HOST
      end

      def historical_endpoint(date)
        "#{HOST}/historical/#{date.strftime('%Y%m%d')}/"
      end

      def already_seen?(symbol)
        Currency.exists?(symbol: symbol)
      end

      def rejected?(symbol)
        already_seen?(symbol) && Currency.find_by!(symbol: symbol).rejected?
      end

      def tradeable_on_supported_exchanges?(name)
        MarketOverview.execute!(name: name).any? { |row|
          row[:tradeable_on_supported_exchanges?]
        }
      end
    end
  end
end
