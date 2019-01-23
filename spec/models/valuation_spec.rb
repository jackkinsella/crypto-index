require 'rails_helper'

RSpec.describe Valuation do
  fixtures :currencies

  let(:timestamp_that_does_not_clash_with_fixtures) {
    Fixtures::DEFAULT_TIMESTAMP + Fixtures::DEFAULT_DURATION +
    Valuation::REFERENCE_INTERVAL + 1.hour
  }
  let(:timestamp) { timestamp_that_does_not_clash_with_fixtures }

  describe 'validations' do
    context 'given the currency has been rejected' do
      let(:currency) { Currency.dao }

      subject { currency.valuations.build(timestamp: timestamp) }

      it 'is invalid' do
        expect(subject.tap(&:valid?).errors).to include(:currency)
      end

      context 'at the exact time of rejection' do
        subject { currency.valuations.build(timestamp: currency.rejected_at) }

        it 'is invalid' do
          expect(subject.tap(&:valid?).errors).to include(:currency)
        end
      end

      context 'at the very instant before the rejection' do
        subject {
          currency.valuations.build(
            timestamp: currency.rejected_at - 10.minutes
          )
        }

        it 'is valid' do
          expect(subject.tap(&:valid?).errors).not_to include(:currency)
        end
      end
    end
  end

  describe 'before validation' do
    let(:currency) { Currency.ltc }

    let(:valuation) {
      currency.valuations.build(timestamp: timestamp, readings: readings).
        tap(&:valid?)
    }

    context 'given that all trusted readings are available' do
      let(:readings) {
        [
          currency.valuation_readings.build(
            source_name: :coin_market_cap,
            market_cap_usd: 1_000_000_000,
            price_usd: 200,
            circulating_supply: 5_000_000
          ),
          currency.valuation_readings.build(
            source_name: :on_chain_fx,
            market_cap_usd: 1_029_000_000,
            price_usd: 210,
            circulating_supply: 4_900_000
          ),
          currency.valuation_readings.build(
            source_name: :cryptowatch,
            price_usd: 190
          )
        ]
      }

      it 'assigns values based on the trusted readings' do
        expect(valuation.price_usd).to eq(205)
        expect(valuation.circulating_supply).to eq(4_950_000)
      end

      it 'derives a new market capitalization from the averaged values' do
        expect(valuation.market_cap_usd).to eq(1_014_750_000)
      end
    end

    context 'given only one trusted reading' do
      let(:readings) {
        [
          currency.valuation_readings.build(
            source_name: :coin_market_cap,
            market_cap_usd: 1_000_000_000,
            price_usd: 200,
            circulating_supply: 5_000_000
          ),
          currency.valuation_readings.build(
            source_name: :cryptowatch,
            price_usd: 190
          )
        ]
      }

      before { Timecop.freeze(current_time) }

      context 'given a recent timestamp' do
        let(:current_time) { timestamp + 25.minutes }

        it 'does not yet assign any values' do
          expect(valuation.market_cap_usd).to be_nil
          expect(valuation.price_usd).to be_nil
          expect(valuation.circulating_supply).to be_nil
        end
      end

      context 'given a slightly earlier timestamp' do
        let(:current_time) { timestamp + 35.minutes }

        it 'assigns values based on the trusted readings' do
          expect(valuation.market_cap_usd).to eq(1_000_000_000)
          expect(valuation.price_usd).to eq(200)
          expect(valuation.circulating_supply).to eq(5_000_000)
        end
      end
    end

    context 'without trusted readings' do
      let(:readings) {
        [
          currency.valuation_readings.build(
            source_name: :on_chain_fx,
            price_usd: 210
          ),
          currency.valuation_readings.build(
            source_name: :cryptowatch,
            price_usd: 190
          )
        ]
      }

      before { Timecop.freeze(current_time) }

      context 'given a recent reference valuation' do
        let(:recent_timestamp) { timestamp - 5.days }

        let(:reading) {
          currency.valuation_readings.at(recent_timestamp).build(
            source_name: :coin_market_cap,
            source_data: {data: {}},
            market_cap_usd: 736_000_000,
            price_usd: 160,
            circulating_supply: 4_600_000
          )
        }

        before {
          currency.valuations.at(recent_timestamp).create!(
            readings: [reading]
          )
        }

        context 'given a recent timestamp' do
          let(:current_time) { timestamp + 25.minutes }

          it 'does not yet assign any values' do
            expect(valuation.market_cap_usd).to be_nil
            expect(valuation.price_usd).to be_nil
            expect(valuation.circulating_supply).to be_nil
          end
        end

        context 'given a slightly earlier timestamp' do
          let(:current_time) { timestamp + 35.minutes }

          it 'assigns values based on all readings and the recent valuation' do
            expect(valuation.price_usd).to eq(200)
            expect(valuation.circulating_supply).to eq(4_600_000)
          end
        end
      end

      context 'without a recent reference valuation' do
        context 'given a recent timestamp' do
          let(:current_time) { timestamp + 25.minutes }

          it 'does not assign any values' do
            expect(valuation.market_cap_usd).to be_nil
            expect(valuation.price_usd).to be_nil
            expect(valuation.circulating_supply).to be_nil
          end
        end

        context 'given a slightly earlier timestamp' do
          let(:current_time) { timestamp + 35.minutes }

          it 'does not assign any values' do
            expect(valuation.market_cap_usd).to be_nil
            expect(valuation.price_usd).to be_nil
            expect(valuation.circulating_supply).to be_nil
          end
        end
      end
    end
  end

  describe 'delegations' do
    let(:indicator) {
      Valuation::Indicator.new(
        market_cap_usd_moving_average_24h: 14_400_000,
        price_usd_moving_average_24h: 12,
        circulating_supply_moving_average_24h: 1_200_000,
        price_change_24h: 0.05,
        price_change_24h_percent: 5
      )
    }

    subject { Valuation.new(indicator: indicator) }

    describe '#market_cap_usd_moving_average_24h' do
      it 'is delegated to `indicator`' do
        expect(subject.market_cap_usd_moving_average_24h).to eq(14_400_000)
      end
    end

    describe '#price_usd_moving_average_24h' do
      it 'is delegated to `indicator`' do
        expect(subject.price_usd_moving_average_24h).to eq(12)
      end
    end

    describe '#circulating_supply_moving_average_24h' do
      it 'is delegated to `indicator`' do
        expect(subject.circulating_supply_moving_average_24h).to eq(1_200_000)
      end
    end

    describe '#price_change_24h' do
      it 'is delegated to `indicator`' do
        expect(subject.price_change_24h).to eq(0.05)
      end
    end

    describe '#price_change_24h_percent' do
      it 'is delegated to `indicator`' do
        expect(subject.price_change_24h_percent).to eq(5)
      end
    end
  end

  describe '#score' do
    let(:currency) { Currency.ltc }

    let(:timestamp) { Fixtures::DEFAULT_TIMESTAMP + 1.week }

    let(:readings) {
      [
        currency.valuation_readings.create!(
          timestamp: timestamp,
          source_name: :coin_market_cap,
          source_data: {data: {}},
          market_cap_usd: 1_000_000_000,
          price_usd: 200,
          circulating_supply: 5_000_000
        ),
        currency.valuation_readings.create!(
          timestamp: timestamp,
          source_name: :crypto_compare,
          source_data: {data: {}},
          market_cap_usd: 900_000_000
        ),
        currency.valuation_readings.create!(
          timestamp: timestamp,
          source_name: :cryptowatch,
          source_data: {data: {}},
          price_usd: 205
        ),
        currency.valuation_readings.create!(
          timestamp: timestamp,
          source_name: :on_chain_fx,
          source_data: {data: {}},
          market_cap_usd: 1_050_000_000
        )
      ]
    }

    subject {
      Valuation.at(timestamp).for(currency).new(readings: [readings.first])
    }

    it 'returns the number of trusted evaluated readings ' \
       'in relation to the number of available readings' do
      expect(subject.score).to eq('1(4)')
    end
  end
end
