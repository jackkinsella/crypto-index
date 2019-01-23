class Valuation
  class Indicator < ApplicationView
    include Timestamped

    self.primary_key = :valuation_id

    belongs_to :valuation

    validates :market_cap_usd_moving_average_24h,
      numericality: {
        greater_than: 0, less_than: Valuable::MAXIMUM_MARKET_CAP_USD
      }

    validates :price_usd_moving_average_24h,
      numericality: {
        greater_than: 0
      }

    validates :circulating_supply_moving_average_24h,
      numericality: {
        greater_than: 0, less_than_or_equal_to: ->(valuation) {
          valuation.maximum_supply || 'Infinity'.to_d
        },
        message: ->(valuation, _) {
          "cannot be greater than #{valuation.maximum_supply}"
        }
      }

    validates :price_change_24h,
      numericality: true

    validates :price_change_24h_percent,
      numericality: {
        greater_than_or_equal_to: -100
      }

    delegate_missing_to :valuation

    scope :by_market_cap_over_24h, -> {
      order(market_cap_usd_moving_average_24h: :desc)
    }

    scope :by_price_over_24h, -> {
      order(price_usd_moving_average_24h: :desc)
    }

    scope :by_circulating_supply_over_24h, -> {
      order(circulating_supply_moving_average_24h: :desc)
    }

    def self.build_missing_for(valuation)
      @_valuation_indicators_sql = File.read(
        Dir["#{Rails.root}/db/views/valuation_indicators_v*.sql"].sort.last
      )

      last_24hr_timestamps = Time.partition_over(valuation.timestamp, 24.hours).
        map { |timestamp| "'#{timestamp}'" }.join(',')

      valuation.build_indicator(
        valuation.class.connection.execute(
          @_valuation_indicators_sql.insert(
            @_valuation_indicators_sql.index('WINDOW') - 1,
            <<~SQL
               WHERE currency_id = '#{valuation.currency_id}'
              AND timestamp IN (#{last_24hr_timestamps})
            SQL
          )
        ).find { |result| result['valuation_id'] == valuation.id }
      )
    end

    def readonly?
      true
    end

    def to_s
      symbol
    end
  end
end
