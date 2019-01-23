require 'rails_helper'

module Sources
  RSpec.describe Cryptowatch do
    fixtures :currencies

    it_behaves_like 'Source'

    describe '#data_for' do
      let(:date) { Date.parse('2018-05-14') }

      let(:currency) { Currency.btc }

      let(:current_time) { Time.new(2018, 5, 14, 12, 1) }

      before { Timecop.freeze(current_time) }

      before {
        stub_request_with_recording :get,
          'https://api.cryptowat.ch/markets/prices'
      }

      context 'given a request right after the full hour' do
        context 'when Cryptowatch is up' do
          context 'given Bitcoin' do
            it 'returns one valuation' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].size
              ).to be(1)
            end

            it 'returns the current timestamp' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].first[:timestamp]
              ).to eq(current_time)
            end

            it 'returns the average USD price over all markets' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].first[:price_usd]
              ).to be_within(1e-2).of(8_502.49)
            end

            it 'returns `nil` for the BTC price' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].first[:price_btc]
              ).to be_nil
            end

            it 'returns the market prices for Bitcoin only' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].first[:market_prices].keys
              ).to all(match(/btcusd\z/))
            end
          end

          context 'given Cryptowatch lists the currency' do
            let(:currency) { Currency.eth }

            it 'returns one valuation' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].size
              ).to be(1)
            end

            it 'returns the average BTC price over all markets' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].first[:price_btc]
              ).to be_within(1e-5).of(0.08342)
            end
          end

          context 'given Cryptowatch does not list the currency' do
            let(:currency) { Currency.dao }

            it 'returns no data' do
              expect(subject.data_for(date: date, currency: currency)).to eq(
                valuations: []
              )
            end
          end

          context 'given a historical date' do
            let(:date) { Date.parse('2018-01-01') }

            it 'returns no data' do
              expect(subject.data_for(date: date, currency: currency)).to eq(
                valuations: []
              )
            end
          end
        end

        context 'when Cryptowatch is down' do
          let(:url) {
            'https://api.cryptowat.ch/markets/prices'
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
      end

      context 'given a request after the valid interval' do
        let(:current_time) { Time.new(2018, 5, 14, 12, 6, 30) }

        it 'returns no data' do
          expect(subject.data_for(date: date, currency: currency)).to eq(
            valuations: []
          )
        end
      end
    end
  end
end
