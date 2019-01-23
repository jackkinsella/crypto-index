require 'rails_helper'

module Sources
  RSpec.describe CoinMarketCap do
    fixtures :currencies

    describe '#data_for' do
      let(:date) { Date.parse('2018-01-01') }

      let(:currency) { Currency.btc }

      context 'when CoinMarketCap is up' do
        context 'given Bitcoin' do
          context 'given a historical date' do
            before {
              stub_request_with_recording :get,
                'https://graphs2.coinmarketcap.com/currencies/bitcoin/' \
                '1514764800000/1514851200000/'
            }

            it 'returns 24 valuations' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].size
              ).to be(24)
            end

            it 'returns the correct timestamps' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].first[:timestamp]
              ).to eq(Time.parse('1 Jan 2018 00:04:19'))
            end

            it 'returns the correct USD market capitalizations' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].first[:market_cap_usd]
              ).to be(236_724_393_290)
            end

            it 'returns the correct USD prices' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].first[:price_usd]
              ).to be(14_112.2)
            end

            it 'returns the correct BTC prices' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].first[:price_btc]
              ).to eq(1)
            end

            it 'returns the correct USD volumes' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].first[:volume_usd]
              ).to be(12_139_200_000)
            end
          end

          context 'given the current date' do
            let(:current_time) { Time.new(2018, 5, 12, 16, 35) }

            let(:date) { current_time.to_date }

            before {
              stub_request_with_recording :get,
                'https://graphs2.coinmarketcap.com/currencies/bitcoin/' \
                '1526083200000/1526169600000/'
            }

            it 'returns as many valuations as available' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].size
              ).to be(17)
            end
          end

          context 'given a request at the exact full hour' do
            let(:current_time) { Time.new(2018, 5, 14, 11) }

            let(:date) { current_time.to_date }

            before {
              stub_request_with_recording :get,
                'https://graphs2.coinmarketcap.com/currencies/bitcoin/' \
                '1526256000000/1526342400000/'
            }

            it 'misses the most recent valuation' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].size
              ).to be(12 - 1)
            end
          end
        end
      end

      context 'when CoinMarketCap is down' do
        let(:url) {
          'https://graphs2.coinmarketcap.com/currencies/bitcoin/' \
          '1514764800000/1514851200000/'
        }

        before {
          stub_request(:get, url).to_return status: 500
        }

        it 'raises an error' do
          expect {
            subject.data_for(date: date, currency: currency)
          }.to raise_error(Requests::DownError)
        end
      end

      context 'given a non-existing currency on CoinMarketCap' do
        let(:currency) { Currency.new(symbol: 'DEAD', name: 'deadcoin') }

        let(:url) {
          'https://graphs2.coinmarketcap.com/currencies/deadcoin/' \
          '1514764800000/1514851200000/'
        }

        before {
          stub_request(:get, url).to_return status: 404
        }

        it 'raises an error' do
          expect {
            subject.data_for(date: date, currency: currency)
          }.to raise_error(Requests::NotFoundError)
        end
      end

      context 'given missing data on CoinMarketCap' do
        let(:date) { Date.parse('2018-05-09') }

        let(:currency) { Currency.bcn }

        before {
          stub_request_with_recording :get,
            'https://graphs2.coinmarketcap.com/currencies/bytecoin-bcn/' \
            '1525824000000/1525910400000/'
        }

        it 'returns no data' do
          expect(subject.data_for(date: date, currency: currency)).to eq(
            valuations: []
          )
        end
      end
    end
  end
end
