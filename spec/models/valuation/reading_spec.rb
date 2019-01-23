require 'rails_helper'

RSpec.describe Valuation::Reading do
  fixtures :currencies, :'valuation/readings'

  let(:timestamp) { Fixtures::DEFAULT_TIMESTAMP }

  describe 'validations' do
    context 'given the currency has been rejected' do
      let(:currency) { Currency.dao }

      subject {
        currency.valuation_readings.build(timestamp: timestamp)
      }

      it 'is invalid' do
        expect(subject.tap(&:valid?).errors).to include(:currency)
      end

      context 'at the exact time of rejection' do
        subject {
          currency.valuation_readings.build(timestamp: currency.rejected_at)
        }

        it 'is invalid' do
          expect(subject.tap(&:valid?).errors).to include(:currency)
        end
      end

      context 'at the very instant before the rejection' do
        subject {
          currency.valuation_readings.build(
            timestamp: currency.rejected_at - 10.minutes
          )
        }

        it 'is valid' do
          expect(subject.tap(&:valid?).errors).not_to include(:currency)
        end
      end
    end
  end

  describe 'scopes' do
    let(:currency) { Currency.btc }

    context 'via `Valuable` concern' do
      describe '.complete' do
        before {
          currency.valuation_readings.asc.last.update_columns(
            market_cap_usd: nil, circulating_supply: nil
          )
        }

        it 'returns readings with all relevant data fields present' do
          expect(
            described_class.complete.pluck(:id)
          ).to match_array(Valuation::Reading.select(&:complete?).pluck(:id))
        end
      end
    end

    describe '.from_source' do
      before {
        FactoryBot.create(:valuation_reading, source_name: 'on_chain_fx')
      }

      it 'returns readings from the specific source name' do
        expect(
          described_class.from_source('on_chain_fx').pluck(:source_name).uniq
        ).to eq(['on_chain_fx'])
      end
    end

    describe '.evaluated' do
      before {
        currency.valuation_readings.asc.last.update_columns(
          valuation_id: nil
        )
      }

      it 'returns readings associated with a valuation' do
        expect(
          described_class.evaluated.pluck(:valuation_id).select(&:nil?)
        ).to be_empty
      end
    end

    describe '.trusted' do
      before {
        currency.valuation_readings.asc.last.update_columns(
          market_cap_usd: nil, circulating_supply: nil
        )
      }

      it 'returns readings from trusted sources that are complete' do
        expect(
          described_class.trusted.pluck(:id)
        ).to match_array(Valuation::Reading.select(&:trusted?).pluck(:id))
      end
    end
  end

  context 'via `Valuable` concern' do
    describe '#complete?' do
      let(:currency) { Currency.btc }

      context 'given missing data fields' do
        subject {
          currency.valuation_readings.build(
            timestamp: timestamp,
            market_cap_usd: 10_000_000
          )
        }

        it 'returns false' do
          expect(subject.tap(&:valid?).complete?).to be(false)
        end
      end

      context 'given all relevant data fields' do
        subject {
          currency.valuation_readings.build(
            timestamp: timestamp,
            market_cap_usd: 10_000_000,
            price_usd: 10
          )
        }

        it 'returns true' do
          expect(subject.tap(&:valid?).complete?).to be(true)
        end
      end
    end
  end

  describe '#trusted?' do
    let(:currency) { Currency.btc }

    context 'from a trusted source' do
      let(:source_name) { :coin_market_cap }

      context 'given missing data fields' do
        subject {
          currency.valuation_readings.build(
            timestamp: timestamp,
            source_name: source_name,
            market_cap_usd: 10_000_000
          )
        }

        it 'returns false' do
          expect(subject.tap(&:valid?).trusted?).to be(false)
        end
      end

      context 'given all relevant data fields' do
        subject {
          currency.valuation_readings.build(
            timestamp: timestamp,
            source_name: source_name,
            market_cap_usd: 10_000_000,
            price_usd: 10
          )
        }

        it 'returns true' do
          expect(subject.tap(&:valid?).trusted?).to be(true)
        end
      end
    end

    context 'from a different source' do
      let(:source_name) { :cryptowatch }

      context 'given missing data fields' do
        subject {
          currency.valuation_readings.build(
            timestamp: timestamp,
            source_name: source_name,
            market_cap_usd: 10_000_000
          )
        }

        it 'returns false' do
          expect(subject.tap(&:valid?).trusted?).to be(false)
        end
      end

      context 'given all relevant data fields' do
        subject {
          currency.valuation_readings.build(
            timestamp: timestamp,
            source_name: source_name,
            market_cap_usd: 10_000_000,
            price_usd: 10
          )
        }

        it 'returns false' do
          expect(subject.tap(&:valid?).trusted?).to be(false)
        end
      end
    end
  end
end
