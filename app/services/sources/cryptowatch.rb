module Sources
  class Cryptowatch < ApplicationService
    include Requests

    PROVIDES = {
      valuations: [
        :timestamp,
        :price_usd,
        :price_btc,
        :market_prices
      ]
    }.freeze

    SUPPORTS = {
      ADA: true, AE: false, AMP: true, BCC: true, BCH: true,
      BCN: true, BNB: true, BTC: true, BTG: true, BTM: true,
      BTS: true, DAO: true, DASH: true, DCR: true, DGB: true,
      DGD: false, DOGE: true, EMC: true, EOS: true, ETC: true,
      ETH: true, FCT: true, GNT: true, ICN: true, ICX: true,
      LSK: true, LTC: true, MAID: true, MIOTA: true, NANO: true,
      NEO: true, NMC: true, NXT: true, OMG: true, ONT: false,
      PIVX: true, PPC: true, PPT: false, QTUM: true, REP: true,
      ROUND: true, SC: true, STEEM: true, STRAT: true, TIPS: true,
      TRX: true, USDT: true, VEN: true, VERI: false, VET: true,
      WAN: false, WAVES: true, XEM: true, XLM: true, XMR: true,
      XVG: true, XRP: true, YBC: true, ZEC: true, ZIL: true,
      ZRX: true
    }.freeze

    SYMBOL_MAPPINGS = {
      MIOTA: :IOT
    }.freeze

    VALID_INTERVAL = 6.minutes

    HOST = 'https://api.cryptowat.ch'.freeze

    def data_for(date:, currency:)
      return nothing if date < Date.today || expired? || !supported?(currency)

      data = filter_by_currency(
        read_api(endpoint, cache_for: VALID_INTERVAL)[:result], currency
      )

      return nothing if data.blank?

      prices_usd = filter_by_currency(data, currency, 'usd').values
      prices_btc = filter_by_currency(data, currency, 'btc').values

      {
        valuations: [
          timestamp: current_time,
          price_usd: prices_usd.mean,
          price_btc: prices_btc.mean,
          market_prices: data
        ]
      }
    end

    def expires?
      true
    end

    private

    def nothing
      {valuations: []}
    end

    def current_time
      cache_key = 'sources::cryptowatch#current_time'
      Rails.cache.fetch(cache_key, expires_in: VALID_INTERVAL) { Time.now }
    end

    def expired?
      Time.now - Time.now.round_down > VALID_INTERVAL
    end

    def supported?(currency)
      SUPPORTS[currency.symbol.to_sym]
    end

    def filter_by_currency(data, base, quote = %w[usd btc])
      symbol = SYMBOL_MAPPINGS[base.symbol.to_sym] || base.symbol
      data.select { |key, _value|
        _exchange, pair = key.to_s.split(':')
        pair =~ /\A#{symbol.to_s.downcase}(#{Array(quote).join('|')})\z/
      }
    end

    def endpoint
      'https://api.cryptowat.ch/markets/prices'
    end
  end
end
