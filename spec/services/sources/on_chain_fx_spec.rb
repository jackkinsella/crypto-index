require 'rails_helper'

module Sources
  RSpec.describe OnChainFX do
    fixtures :currencies

    it_behaves_like 'Source'

    describe '#data_for' do
      let(:date) { Date.parse('2018-05-14') }

      let(:currency) { Currency.btc }

      let(:current_time) { Time.new(2018, 5, 14, 12, 1) }

      before { Timecop.freeze(current_time) }

      before {
        stub_request_with_recording :get,
          'https://onchainfx.com/asset/bitcoin'
      }

      context 'given a request right after the full hour' do
        context 'when OnChainFX is up' do
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

            it 'returns the correct USD price' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].first[:price_usd]
              ).to eq(8_396)
            end

            it 'returns the correct circulating supply' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].first[:circulating_supply]
              ).to eq(17_032_937)
            end

            it 'returns the correct USD volume' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].first[:volume_usd]
              ).to eq(6_500_000_000)
            end

            it 'returns `nil` for the BTC price' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].first[:price_btc]
              ).to be_nil
            end
          end

          context 'given OnChainFX lists the currency' do
            let(:currency) { Currency.eth }

            before {
              stub_request_with_recording :get,
                'https://onchainfx.com/asset/ethereum'
            }

            it 'returns one valuation' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].size
              ).to be(1)
            end
          end

          context 'given OnChainFX does not list the currency' do
            let(:currency) { Currency.dao }

            it 'returns no data' do
              expect(subject.data_for(date: date, currency: currency)).to eq(
                currency: {}, valuations: []
              )
            end
          end

          context 'given a historical date' do
            let(:date) { Date.parse('2018-01-01') }

            it 'returns no data' do
              expect(subject.data_for(date: date, currency: currency)).to eq(
                currency: {}, valuations: []
              )
            end
          end
        end

        context 'when OnChainFX is down' do
          let(:url) {
            'https://onchainfx.com/asset/bitcoin'
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
            currency: {}, valuations: []
          )
        end
      end
    end
  end
end
