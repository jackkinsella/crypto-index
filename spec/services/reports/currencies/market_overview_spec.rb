require 'rails_helper'

module Reports
  module Currencies
    RSpec.describe MarketOverview do
      before {
        stub_request_with_recording :get,
        'https://coinmarketcap.com/currencies/bitcoin/'
      }

      describe '#execute!' do
        it 'returns market details for all exchanges dealing in a currency' do
          results = described_class.execute!(name: 'bitcoin')
          expect(results.first[:exchange]).to eq('Binance')
        end
      end
    end
  end
end
