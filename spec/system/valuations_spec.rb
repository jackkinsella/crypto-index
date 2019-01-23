require 'rails_helper'

RSpec.describe 'Valuations' do
  let(:timestamp) { Time.parse('2018-01-01') }
  let(:currencies) { %w[BTC ETH] }

  context 'historical data' do
    before {
      %w[
        https://graphs2.coinmarketcap.com/currencies/bitcoin/1514764800000/1514851200000/
        https://graphs2.coinmarketcap.com/currencies/ethereum/1514764800000/1514851200000/

        https://min-api.cryptocompare.com/data/histohour?fsym=BTC&limit=24&toTs=1514851200&tsym=USD
        https://min-api.cryptocompare.com/data/histohour?fsym=ETH&limit=24&toTs=1514851200&tsym=USD
      ].each do |url|
        stub_request_with_recording :get, url
      end
    }

    it 'works' do
      Valuations::CreateJob.perform_now(
        from_date: timestamp.to_s, to_date: timestamp.to_s,
        currencies: currencies
      )

      expect(Valuation::Reading.at(timestamp).count).to eq(4)
      expect(Valuation.at(timestamp).count).to eq(2)
      expect(Currency.btc.valuations.at(timestamp).take.price_usd).
        to eq(14_112.2)
    end
  end

  context 'real time data' do
    # Note: This test combines real-time and historical data in order to reduce
    # the number of web recordings required. As a result, the prices given are
    # bogus for the timestamp.
    before {
      Timecop.travel(timestamp)

      %w[
        https://graphs2.coinmarketcap.com/currencies/bitcoin/1514764800000/1514851200000/
        https://graphs2.coinmarketcap.com/currencies/ethereum/1514764800000/1514851200000/

        https://min-api.cryptocompare.com/data/histohour?fsym=BTC&limit=24&toTs=1514851200&tsym=USD
        https://min-api.cryptocompare.com/data/histohour?fsym=ETH&limit=24&toTs=1514851200&tsym=USD

        https://api.cryptowat.ch/markets/prices

        https://onchainfx.com/asset/bitcoin
        https://onchainfx.com/asset/ethereum
      ].each do |url|
        stub_request_with_recording :get, url
      end
    }

    it 'works' do
      # FIXME: Due to how `Currency.current_by_market_cap` is implemented, it
      # will always show 'future data', irregardless of Timecop travel. This
      # meant that integration tests of CurrenciesController#index were always
      # incorrect unless I deleted the other fixture data getting in the way.
      # But this slows down tests... a better fix would if
      # Currency.current_by_market_cap ignored timestamps that are in the
      # future.
      Valuation::Reading.where('timestamp >= ? ', timestamp).delete_all
      Valuation.where('timestamp >= ? ', timestamp).delete_all

      Valuations::CreateJob.perform_now(
        from_date: timestamp.to_s, to_date: timestamp.to_s,
        currencies: currencies
      )

      visit currencies_path

      # it gives correct data for Bitcoin on /currencies
      btc_price = find('tr#BTC td:nth-child(4)').text.extract_d
      expect(btc_price.round).to eq(11_254)

      # it gives correct data for Ethereum on /currencies/ethereum
      click_link 'Ethereum'

      # FIXME: Capybara thinks this h2 is invisible
      eth_price = find('h2.subtitle', visible: false).text.extract_d
      expect(eth_price.round).to eq(730)
    end
  end
end
