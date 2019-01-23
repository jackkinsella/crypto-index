module Valuable
  extend ActiveSupport::Concern

  MAXIMUM_MARKET_CAP_USD = 5_000_000_000_000

  included do
    validate do
      if complete?
        deviation = 1 - circulating_supply * price_usd / market_cap_usd

        unless deviation.abs < 1e-5
          errors[:market_cap_usd] << 'must equal price x circulating supply'
        end
      end
    end

    delegate :symbol, :name, :title, :maximum_supply, to: :currency

    before_validation do
      if market_cap_usd.present? && circulating_supply.present?
        self.price_usd ||= (market_cap_usd / circulating_supply)
      end

      if circulating_supply.present? && price_usd.present?
        self.market_cap_usd ||= (circulating_supply * price_usd)
      end

      if price_usd.present? && market_cap_usd.present?
        self.circulating_supply ||= (market_cap_usd / price_usd)

        if circulating_supply.floor == maximum_supply
          self.circulating_supply = maximum_supply
        end
      end
    end

    scope :for, ->(currency) { where(currency: currency) }

    scope :complete, -> {
      where.not(
        market_cap_usd: nil,
        price_usd: nil,
        circulating_supply: nil
      )
    }

    scope :by_market_cap, -> {
      order(market_cap_usd: :desc)
    }

    scope :by_price, -> {
      order(price_usd: :desc)
    }

    scope :by_circulating_supply, -> {
      order(circulating_supply: :desc)
    }
  end

  class_methods do
    def validates_market_cap(allow_nil: false)
      validates :market_cap_usd,
        numericality: {
          greater_than: 0, less_than: MAXIMUM_MARKET_CAP_USD
        },
        allow_nil: allow_nil
    end

    def validates_price_usd(allow_nil: false)
      validates :price_usd,
        numericality: {
          greater_than: 0
        },
        allow_nil: allow_nil
    end

    def validates_circulating_supply(allow_nil: false)
      validates :circulating_supply,
        numericality: {
          greater_than: 0, less_than_or_equal_to: ->(valuable) {
            valuable.maximum_supply || 'Infinity'.to_d
          },
          message: ->(valuable, _) {
            "cannot be greater than #{valuable.maximum_supply}"
          }
        },
        allow_nil: allow_nil
    end
  end

  def complete?
    market_cap_usd.present? &&
    price_usd.present? &&
    circulating_supply.present?
  end
end
