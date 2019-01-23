require 'rails_helper'

RSpec.describe 'Currencies' do
  fixtures :currencies, :valuations

  context 'given indicator data in the materialized view' do
    before {
      visit currencies_path
    }

    it 'displays "Change (24h)"' do
      price_change_24h_percent = find('tr#BTC td:last-child').text.to_d
      expect(price_change_24h_percent.abs).to be > 0
    end
  end

  context 'given no indicator data in the materialized view' do
    let(:current_valuation) { Currency.btc.current_valuation }
    let(:timestamp) { current_valuation.timestamp + 1.hour }

    def encounter_valuation_without_indicator
      Timecop.travel(timestamp)

      next_valuation = current_valuation.dup
      next_valuation.timestamp = timestamp
      next_valuation.save(validate: false)
    end

    def expect_missing_indicator!
      latest_valuation_id = Valuation.where(timestamp: timestamp).first.id
      expect {
        Valuation::Indicator.find(latest_valuation_id)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    before {
      encounter_valuation_without_indicator
      visit currencies_path
    }

    it 'still displays "Change (24h)"' do
      expect_missing_indicator!

      price_change_24h_percent = find('tr#BTC td:last-child').text.to_d
      expect(price_change_24h_percent.abs).to be > 0
    end
  end
end
