require 'rails_helper'

module Sources
  RSpec.describe CryptoCompare do
    fixtures :currencies

    describe '#data_for' do
      let(:date) { Date.parse('2018-01-01') }

      let(:currency) { Currency.btc }

      context 'when CryptoCompare is up' do
        context 'given Bitcoin' do
          context 'given a historical date' do
            before {
              stub_request_with_recording :get,
                'https://min-api.cryptocompare.com/data/histohour?' \
                'fsym=BTC&tsym=USD&limit=24&toTs=1514851200'
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
              ).to eq(Time.parse('1 Jan 2018 00:00:00'))
            end

            it 'returns the correct USD prices' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].first[:price_usd]
              ).to be(13_850.49)
            end

            it 'returns the correct USD volumes' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].first[:volume_usd]
              ).to be(54_143_167.56)
            end
          end

          context 'given the current date' do
            let(:current_time) { Time.new(2018, 5, 14, 11, 52) }

            let(:date) { current_time.to_date }

            before {
              stub_request_with_recording :get,
                'https://min-api.cryptocompare.com/data/histohour?' \
                'fsym=BTC&tsym=USD&limit=24&toTs=1526342400'
            }

            it 'returns as many valuations as available' do
              expect(
                subject.data_for(
                  date: date, currency: currency
                )[:valuations].size
              ).to be(12)
            end
          end
        end

        context 'given missing data' do
          let(:date) { Date.parse('2018-05-09') }

          let(:currency) { Currency.sc }

          before {
            stub_request_with_recording :get,
              'https://min-api.cryptocompare.com/data/histohour?' \
              'fsym=SC&tsym=USD&limit=24&toTs=1525910400'
          }

          it 'returns no data' do
            expect(subject.data_for(date: date, currency: currency)).to eq(
              valuations: []
            )
          end
        end
      end

      context 'when CryptoCompare is down' do
        let(:url) {
          'https://min-api.cryptocompare.com/data/histohour?' \
          'fsym=BTC&tsym=USD&limit=24&toTs=1514851200'
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
  end
end
