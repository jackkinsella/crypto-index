require 'rails_helper'

RSpec.describe Valuation::Indicator do
  fixtures :currencies, :valuations

  let(:currency) { Currency.btc }

  let(:last_24_valuations) { currency.valuations.asc.last(24) }

  before {
    Valuation::Indicator.refresh
  }

  subject { currency.current_valuation.indicator }

  describe '#market_cap_usd_moving_average_24h' do
    it 'returns the mean of `market_cap_usd` over 24 hours' do
      mean = last_24_valuations.pluck(:market_cap_usd).mean

      expect(
        subject.market_cap_usd_moving_average_24h
      ).to be_within(1e-8).of(mean)
    end
  end

  describe '#price_usd_moving_average_24h' do
    it 'returns the mean of `price_usd` over 24 hours' do
      mean = last_24_valuations.pluck(:price_usd).mean

      expect(
        subject.price_usd_moving_average_24h
      ).to be_within(1e-8).of(mean)
    end
  end

  describe '#circulating_supply_moving_average_24h' do
    it 'returns the mean of `circulating_supply` over 24 hours' do
      mean = last_24_valuations.pluck(:circulating_supply).mean

      expect(
        subject.circulating_supply_moving_average_24h
      ).to be_within(1e-8).of(mean)
    end
  end

  describe '#price_change_24h' do
    it 'returns the absolute price difference over 24 hours' do
      expect(subject.price_change_24h).to eq(
        last_24_valuations.last.price_usd -
        last_24_valuations.first.price_usd
      )
    end
  end

  describe '#price_change_24h' do
    it 'returns the relative price difference over 24 hours in percent' do
      expect(subject.price_change_24h_percent).to be_within(0.00001).of(
        (
          last_24_valuations.last.price_usd /
          last_24_valuations.first.price_usd - 1
        ) * 100
      )
    end
  end

  describe 'scopes' do
    let(:timestamp) { described_class.end_time }

    describe '.by_market_cap_over_24h' do
      it 'sorts by `market_cap_usd_moving_average_24h` descending' do
        expect(
          described_class.at(timestamp).by_market_cap_over_24h.to_a
        ).to eq(
          Valuation::Indicator.at(timestamp).sort_by(
            &:market_cap_usd_moving_average_24h
          ).reverse
        )
      end
    end

    describe '.by_price_over_24h' do
      it 'sorts by `price_usd_moving_average_24h` descending' do
        expect(
          described_class.at(timestamp).by_price_over_24h.to_a
        ).to eq(
          Valuation::Indicator.at(timestamp).sort_by(
            &:price_usd_moving_average_24h
          ).reverse
        )
      end
    end

    describe '.by_circulating_supply_over_24h' do
      it 'sorts by `circulating_supply_moving_average_24h` descending' do
        expect(
          described_class.at(timestamp).by_circulating_supply_over_24h.to_a
        ).to eq(
          Valuation::Indicator.at(timestamp).sort_by(
            &:circulating_supply_moving_average_24h
          ).reverse
        )
      end
    end
  end

  describe '.build_missing_for' do
    let(:valuation) { Currency.btc.current_valuation }

    it 'returns the same result as the materialized view' do
      expect(
        described_class.build_missing_for(valuation).attributes
      ).to eq(
        described_class.find(valuation.id).attributes
      )
    end
  end

  describe '#readonly?' do
    it 'is true' do
      expect(subject.readonly?).to be(true)
    end
  end

  describe '#to_s' do
    it 'returns the currency symbol' do
      expect(subject.to_s).to eq('BTC')
    end
  end
end
