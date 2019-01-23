require 'rails_helper'

RSpec.describe Index::Allocation do
  fixtures :currencies, :indexes, :'index/allocations',
    :'index/components', :valuations

  describe 'before validation' do
    let(:index) { Index.m10 }

    let(:timestamp) { Fixtures::DEFAULT_TIMESTAMP }

    let(:symbols_in_index) {
      Fixtures::CURRENCY_SYMBOLS_IN_M10_AT[:default_timestamp]
    }

    let(:components) {
      symbols_in_index.map do |symbol|
        Index::Component.new(currency: Currency.send(symbol), weight: 20)
      end
    }

    subject {
      index.allocations.build(components: components, timestamp: timestamp)
    }

    it 'calculates the value correctly' do
      current_market_cap = symbols_in_index.inject(0) { |accum, symbol|
        accum + Fixtures.market_cap_for(symbol, timestamp)
      }
      genesis_market_cap = Index::Allocation.at_genesis_date(index).components.
        sum(&:market_cap_usd)

      expected_value = 100 * current_market_cap / genesis_market_cap
      expect(subject.tap(&:valid?).value.round).to eq(expected_value.round)
    end

    it 'normalizes the component weights correctly' do
      expect(subject.tap(&:valid?).components.sum(&:weight)).to eq(1.0)
    end

    it 'adjusts all weights proportionally' do
      expect(subject.tap(&:valid?).components.map(&:weight).uniq).to eq([0.1])
    end

    context 'with component weights above the upper capping' do
      before {
        components.find { |component| component.currency == Currency.btc }.
          tap do |component|
            component.weight = 140
          end
        components.find { |component| component.currency == Currency.eth }.
          tap do |component|
          component.weight = 120
        end
      }

      it 'normalizes the component weights correctly' do
        expect(subject.tap(&:valid?).components.sum(&:weight)).to eq(1.0)
      end

      it 'restricts the maximum component weights correctly' do
        expect(
          subject.tap(&:valid?).components.select { |item|
            [Currency.btc, Currency.eth].include?(item.currency)
          }.map(&:weight)
        ).to match([0.25, 0.25])
      end

      it 'adjusts the other weights correctly' do
        expect(
          subject.tap(&:valid?).components.find { |item|
            item.currency == Currency.xrp
          }.weight
        ).to match(0.5 / 8)
      end
    end

    context 'with component weights above the upper capping' do
      before {
        components[-2..-1] = [
          Index::Component.new(currency: Currency.trx, weight: 1),
          Index::Component.new(currency: Currency.miota, weight: 1)
        ]
      }

      it 'restricts the minimum component weights correctly' do
        expect(
          subject.tap(&:valid?).components.select { |item|
            [Currency.trx, Currency.miota].include?(item.currency)
          }.map(&:weight)
        ).to match([0.01, 0.01])
      end

      it 'adjusts the other weights correctly' do
        expect(
          subject.tap(&:valid?).components.find { |item|
            item.currency == Currency.xrp
          }.weight
        ).to match(0.98 / 8)
      end
    end
  end
end
