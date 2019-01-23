module Sources
  class OnChainFX < ApplicationService
    include Requests

    PROVIDES = {
      currency: :maximum_supply,
      valuations: [
        :timestamp,
        :price_usd,
        :circulating_supply,
        :volume_usd
      ]
    }.freeze

    SUPPORTS = {
      ADA: true, AE: true, AMP: false, BCC: false, BCH: true,
      BCN: true, BNB: true, BTC: true, BTG: true, BTM: true,
      BTS: true, DAO: false, DASH: true, DCR: true, DGB: true,
      DGD: true, DOGE: true, EMC: false, EOS: true, ETC: true,
      ETH: true, FCT: true, GNT: true, ICN: true, ICX: true,
      LSK: true, LTC: true, MAID: true, MIOTA: true, NANO: true,
      NEO: true, NMC: false, NXT: false, OMG: true, ONT: true,
      PIVX: true, PPC: false, PPT: true, QTUM: true, REP: true,
      ROUND: false, SC: true, STEEM: true, STRAT: true, TIPS: false,
      TRX: true, USDT: false, VEN: false, VERI: false, VET: true,
      WAN: true, WAVES: true, XEM: true, XLM: true, XMR: true,
      XVG: true, XRP: true, YBC: false, ZEC: true, ZIL: true,
      ZRX: true
    }.freeze

    NAME_MAPPINGS = {
      maidsafecoin: :maidsafe
    }.freeze

    VALID_INTERVAL = 6.minutes

    HOST = 'https://onchainfx.com'.freeze

    def data_for(date:, currency:)
      return nothing if date < Date.today || expired? || !supported?(currency)

      self.page = Nokogiri::HTML(read_page(endpoint_for(currency)))

      {
        currency: {
          maximum_supply: extract_supply_row(/Y2050 supply (\(est\.\))?/)
        },
        valuations: [
          {
            timestamp: Time.now,
            price_usd: extract_snapshot_row(:"Price (USD)"),
            circulating_supply: extract_supply_row(:'Current supply'),
            volume_usd: extract_snapshot_row(:'24hr Trade Volume')
          }
        ]
      }
    end

    def expires?
      true
    end

    private

    attr_accessor :page

    def nothing
      {currency: {}, valuations: []}
    end

    def expired?
      Time.now - Time.now.round_down > VALID_INTERVAL
    end

    def supported?(currency)
      SUPPORTS[currency.symbol.to_sym]
    end

    def extract_supply_row(regexp)
      page.css('.asset_propset .supply_item_row').text.
        match(/#{regexp}\t[^\t]+/)&.to_s&.split("\t")&.last&.extract_d
    end

    def extract_snapshot_row(label)
      page.css('.asset_propset .km_item_row').text.split("\t").drop(1).
        each_slice(2).to_h.symbolize_keys[label]&.extract_d
    end

    def endpoint_for(currency)
      name = NAME_MAPPINGS[currency.to_sym] || currency.to_sym
      "#{HOST}/asset/#{name}"
    end
  end
end
