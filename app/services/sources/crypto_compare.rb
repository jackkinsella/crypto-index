module Sources
  class CryptoCompare < ApplicationService
    include Requests

    PROVIDES = {
      valuations: [
        :timestamp,
        :price_usd,
        :volume_usd
      ]
    }.freeze

    HOST = 'https://min-api.cryptocompare.com'.freeze

    SYMBOL_MAPPINGS = {
      MIOTA: :IOT
    }.freeze

    def data_for(date:, currency:)
      from = date.to_time
      to = (date + 1.day).to_time

      return nothing if broken_data?(date, currency)

      {
        valuations: extract(
          read_api(endpoint_for(currency, from: from, to: to))
        ).select { |item|
          Time.at(item[:timestamp]) >= from &&
          Time.at(item[:timestamp]) < to
        }
      }
    end

    def expires?
      false
    end

    private

    def nothing
      {valuations: []}
    end

    def extract(data)
      return [] unless data[:Response] == 'Success'

      data[:Data].map { |item|
        next if item[:open].to_s == '0'
        {
          timestamp: Time.at(item[:time]),
          price_usd: item[:open],
          volume_usd: item[:volumeto]
        }
      }.compact
    end

    def broken_data?(date, currency)
      date < Date.new(2018, 8, 6) && currency.symbol == 'VET'
    end

    def endpoint_for(currency, from:, to:)
      symbol = SYMBOL_MAPPINGS[currency.symbol.to_sym] || currency.symbol
      limit = (to - from) / 1.hour
      "#{HOST}/data/histohour?" \
      "fsym=#{symbol}&tsym=USD&limit=#{limit.ceil}&toTs=#{to.to_i}"
    end
  end
end
