require 'rails_helper'

module Reports
  module Currencies
    RSpec.describe MaximumMarketCap do
      before {
        allow(MarketOverview).to receive(:execute!).and_return([])
      }

      describe '#execute!' do
        context 'when date is today' do
          before {
            stub_request_with_recording :get, 'https://coinmarketcap.com/'
          }

          it 'lists the top currencies by market capitalization' do
            results = described_class.execute!(date: Date.today)
            expect(results.first[:name]).to eq('bitcoin')
          end
        end

        context 'when date is in the past' do
          before {
            stub_request_with_recording :get, 'https://coinmarketcap.com/historical/20180513/'
          }

          let(:date) { Date.parse('13th May 2018') }

          it 'lists the top currencies by market capitalization' do
            results = described_class.execute!(date: date)
            expect(results.first[:name]).to eq('bitcoin')
          end
        end
      end
    end
  end
end
