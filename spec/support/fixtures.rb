module Fixtures
  extend ActiveSupport::Concern

  GENESIS_VALUATION_TIMESTAMP = CryptoIndex::GENESIS_DATE.to_time - 24.hours

  DEFAULT_TIMESTAMP = Time.parse('10 Jan 2018')
  DEFAULT_DURATION = 2.days

  REBALANCING_TIMESTAMP = Time.parse('Feb 2 2018 12:00')
  UNALLOCATED_TIMESTAMP = REBALANCING_TIMESTAMP + DEFAULT_DURATION

  # TODO: This constant, once it becomes implicit in the pricing
  # functions, can be derived from them.
  CURRENCY_SYMBOLS_IN_M10_AT = {
    genesis: %w[BTC ETH XRP LTC XMR ETC DASH MAID REP STEEM],
    default_timestamp: %w[BTC XRP ETH BCH ADA LTC XEM XLM TRX MIOTA]
  }.freeze

  OTHER_CURRENCY_SYMBOLS = %w[DAO BNB BCN SC].freeze

  CURRENCY_SYMBOLS = (CURRENCY_SYMBOLS_IN_M10_AT.values.flatten +
    OTHER_CURRENCY_SYMBOLS).uniq

  class << self
    def price_for(symbol, timestamp = Time.now)
      base = base_price_for(symbol)
      base + (base * deterministic_noise(timestamp, symbol))
    end

    def circulating_supply_for(symbol, timestamp = Time.now)
      proposed_supply =
        base_circulating_supply_for(symbol) +
        deterministic_noise(timestamp, symbol)

      currency = Currency.send(symbol)
      if currency && proposed_supply > currency.maximum_supply
        currency.maximum_supply
      else
        proposed_supply
      end
    end

    def market_cap_for(symbol, timestamp = Time.now)
      price_for(symbol, timestamp) *
        circulating_supply_for(symbol, timestamp)
    end

    def exchange_rate(base_symbol, quote_symbol, timestamp = Time.now)
      price_for(base_symbol, timestamp) / price_for(quote_symbol, timestamp)
    end

    private

    def base_price_for(symbol)
      prices = {
        BTC: 17_500,
        BCH: 2_750,
        ETH: 1_000,
        LTC: 300,
        MIOTA: 4,
        XRP: 3,
        XEM: 1.5,
        ADA: 1,
        XLM: 0.5,
        TRX: 0.2
      }
      unknown_price = prices.values.min.to_d * 0.5

      prices[symbol.to_sym]&.to_d || unknown_price
    end

    def base_circulating_supply_for(symbol)
      supplies = {
        TRX: 65_000_000_000,
        XRP: 40_000_000_000,
        ADA: 25_000_000_000,
        XLM: 15_000_000_000,
        XEM: 9_000_000_000,
        MIOTA: 3_000_000_000,
        ETH: 100_000_000,
        LTC: 50_000_000,
        BCH: 15_000_000,
        BTC: 15_000_000
      }
      unknown_supply = supplies.values.min.to_d * 0.5

      supplies[symbol.to_sym]&.to_d || unknown_supply
    end

    def deterministic_noise(timestamp, symbol)
      currency_variance = symbol.bytes.sum.to_d / 100
      hours_from_default_timestamp = (timestamp - DEFAULT_TIMESTAMP) / 1.hour

      currency_variance + (hours_from_default_timestamp.to_d / 5_000)
    end
  end
end
