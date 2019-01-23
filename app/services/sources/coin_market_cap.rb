module Sources
  class CoinMarketCap < ApplicationService
    include Requests

    PROVIDES = {
      valuations: [
        :timestamp,
        :market_cap_usd,
        :price_usd,
        :price_btc,
        :volume_usd
      ]
    }.freeze

    NAME_MAPPINGS = {
      bytecoin: :'bytecoin-bcn',
      dao: :'the-dao',
      golem: :'golem-network-tokens'
    }.freeze

    HOST = 'https://graphs2.coinmarketcap.com'.freeze

    def data_for(date:, currency:)
      from = date.to_time
      to = (date + 1.day).to_time
      steps = Time.partition(from, to)

      {
        valuations:
          rekey_by_time(
            read_api(endpoint_for(currency, from: from, to: to))
          ).reject { |time, _|
            discard_entry_at?(time, steps)
          }.values.map { |item|
            item.delete_if { |key, value|
              key == :market_cap_usd && value.to_s == '0'
            }
          }
      }
    end

    def expires?
      false
    end

    private

    def rekey_by_time(data)
      data.each_key.with_object({}) do |key, hash|
        data[key].each do |entry|
          time, value = entry
          time = Time.at(time / 1_000)
          key = :market_cap_usd if key == :market_cap_by_available_supply
          hash[time] ||= {timestamp: time}
          hash[time][key.to_sym] = value if provides?(key)
        end
      end
    end

    def provides?(key)
      PROVIDES[:valuations].include?(key.to_sym)
    end

    def discard_entry_at?(time, steps)
      steps.map { |step| time - step }.all? { |time_difference|
        time_difference.negative? || time_difference > 6.minutes
      }
    end

    def endpoint_for(currency, from:, to:)
      name = NAME_MAPPINGS[currency.to_sym] || currency.to_sym
      "#{HOST}/currencies/#{name}/#{from.to_i * 1_000}/#{to.to_i * 1_000}/"
    end
  end
end
