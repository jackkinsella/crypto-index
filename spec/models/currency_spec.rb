require 'rails_helper'

RSpec.describe Currency do
  fixtures :currencies

  describe 'delegations' do
    let(:valuation) {
      Valuation.new(
        market_cap_usd: 10_000_000,
        price_usd: 10,
        circulating_supply: 1_000_000,
        indicator: Valuation::Indicator.new(
          price_change_24h: 0.05,
          price_change_24h_percent: 5
        )
      )
    }

    subject { Currency.new(current_valuation: valuation) }

    describe '#market_cap_usd' do
      it 'is delegated to `current_valuation`' do
        expect(subject.market_cap_usd).to eq(10_000_000)
      end
    end

    describe '#price_usd' do
      it 'is delegated to `current_valuation`' do
        expect(subject.price_usd).to eq(10)
      end
    end

    describe '#circulating_supply' do
      it 'is delegated to `current_valuation`' do
        expect(subject.circulating_supply).to eq(1_000_000)
      end
    end

    describe '#price_change_24h' do
      it 'is delegated to `current_valuation`' do
        expect(subject.price_change_24h).to eq(0.05)
      end
    end

    describe '#price_change_24h_percent' do
      it 'is delegated to `current_valuation`' do
        expect(subject.price_change_24h_percent).to eq(5)
      end
    end
  end

  describe 'scopes' do
    describe '.current_by_market_cap' do
      context 'when all valuations at the current timestamp are present' do
        let(:timestamp) { Valuation.maximum(:timestamp) }

        it 'returns current top currencies by market capitalization' do
          expect(described_class.current_by_market_cap.first(10).to_a).to eq(
            Currency.not_rejected.joins(:valuations).group(:'currencies.id').
            sort_by(&:market_cap_usd).reverse.first(10)
          )
        end
      end

      context 'when valuations at the current timestamp are missing' do
        fixtures :valuations

        let(:current_timestamp) { Time.now.round_down }
        let(:currency) { Currency.btc }

        it 'returns entries for every currency, using the most ' \
           'recent valuation' do
          results = described_class.current_by_market_cap

          next_most_recent = currency.valuations.
            where(timestamp: Valuation.maximum(:timestamp)).take
          next_most_recent.update_columns(
            market_cap_usd: 10, price_usd: 1, circulating_supply: 10
          )
          currency_with_expected_lowest_market_cap = currency

          expect(results).to include(currency)
          expect(results.last).to eq(
            currency_with_expected_lowest_market_cap
          )
        end
      end
    end
  end

  describe '#to_s' do
    it 'returns the currency symbol' do
      expect(Currency.btc.to_s).to eq('BTC')
    end
  end
end
