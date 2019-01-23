require 'rails_helper'

module Trading
  module Assembly
    RSpec.describe Rebalancing do
      fixtures :indexes, :markets, :'user/portfolios'

      let(:rebalancing) { portfolio.rebalancings.build }
      let(:portfolio) { user_portfolios(:portfolio_for_signed_up) }
      let(:portfolio_value) { 10_000.usd }
      let(:fee_multiplier) { 0.999 }

      let(:prices) {
        proc { |currency|
          case currency.symbol
          when 'BTC' then 100.usd
          when 'ETH' then 10.usd
          when 'XRP' then 5.usd
          when 'MIOTA' then 0.1.usd
          when 'BNB' then 2.5.usd
          else 1.usd
          end
        }
      }

      context 'after the CryptoIndex launch date' do
        before {
          Timecop.travel(Time.new(2018, 7, 25))

          allow_any_instance_of(Currency).to receive(:price_usd, &prices)
          allow_any_instance_of(Currency).to receive(:price_usd_at, &prices)

          allow_any_instance_of(User::Portfolio::Composition).to(
            receive(:mean_squared_error).and_return(0)
          )

          allow_any_instance_of(User::Portfolio).to(
            receive(:current_composition).and_return(
              User::Portfolio::Composition.new(
                value_usd: portfolio_value,
                value_btc: portfolio_value / 100.usd,
                value_eth: portfolio_value / 10.usd,
                return_on_investment: 0,
                constituents: {
                  'ADA' => 0.1 * portfolio_value,
                  'BCH' => 0.1 * portfolio_value,
                  'BTC' => 0.1 * portfolio_value / 100.usd,
                  'DASH' => 0.05 * portfolio_value,
                  'ETH' => 0.15 * portfolio_value / 10.usd,
                  'LTC' => 0.15 * portfolio_value,
                  'MIOTA' => 0.05 * portfolio_value / 0.1.usd,
                  'XLM' => 0.1 * portfolio_value,
                  'XMR' => 0.1 * portfolio_value,
                  'XRP' => 0.1 * portfolio_value / 5.usd
                }
              )
            )
          )

          allow_any_instance_of(Index).to receive(:current_allocation).
            and_return(
              instance_double(
                'Index::Allocation', to_h: {
                  'ADA' => 0.1,
                  'BCH' => 0.1,
                  'BTC' => 0.2,
                  'ETH' => 0.1,
                  'LTC' => 0.05,
                  'MIOTA' => 0.1,
                  'TRX' => 0.1,
                  'XLM' => 0.05,
                  'XMR' => 0.05,
                  'XRP' => 0.15
                }
              )
            )
        }

        describe '#execute!' do
          let(:trades) {
            described_class.execute!(rebalancing: rebalancing).each { |trade|
              trade.tap(&:valid?)
            }
          }

          it 'assembles the correct number of trades' do
            expect(trades.size).to be(9)
          end

          # TODO: Does this add anything to the other tests?
          xit 'calculates the correct trade amounts' do
            expect(trades.map(&:amount)).to match(
              [495, 990, 4_950, 495, 495, 99, 990, 89, 4]
            )
          end

          it 'does not trade BCHETH or ADAETH' do
            expect(
              trades.select { |item| %w[BCHETH ADAETH].include?(item.symbol) }
            ).to be_empty
          end

          it 'assembles the XRPETH trade correctly' do
            trade = trades.find { |item| item.symbol == 'XRPETH' }

            expect(trade.order_side).to eq('BUY')
            expect(trade.amount).to be_within(0.91).percent_of(
              0.05 * portfolio_value / 5.usd * fee_multiplier
            )
          end

          it 'assembles the EOSETH trade correctly' do
            trade = trades.find { |item| item.symbol == 'XMRETH' }

            expect(trade.order_side).to eq('SELL')
            expect(trade.amount).to eq(0.05 * portfolio_value * fee_multiplier)
          end

          it 'assembles the LTCETH trade correctly' do
            trade = trades.find { |item| item.symbol == 'LTCETH' }

            expect(trade.order_side).to eq('SELL')
            expect(trade.amount).to eq(0.1 * portfolio_value * fee_multiplier)
          end

          it 'assembles the XLMETH trade correctly' do
            trade = trades.find { |item| item.symbol == 'XLMETH' }

            expect(trade.order_side).to eq('SELL')
            expect(trade.amount).to be_within(0.11).percent_of(
              0.05 * portfolio_value * fee_multiplier
            )
          end

          it 'assembles the MIOTAETH trade correctly' do
            trade = trades.find { |item| item.symbol == 'MIOTAETH' }

            expect(trade.order_side).to eq('BUY')
            expect(trade.amount).to eq(
              0.05 * portfolio_value / 0.1.usd * fee_multiplier
            )
          end

          it 'assembles the DASHETH trade correctly' do
            trade = trades.find { |item| item.symbol == 'DASHETH' }

            expect(trade.order_side).to eq('SELL')
            expect(trade.amount).to eq(0.05 * portfolio_value * fee_multiplier)
          end

          it 'assembles the TRXETH trade correctly' do
            trade = trades.find { |item| item.symbol == 'TRXETH' }

            expect(trade.order_side).to eq('BUY')
            expect(trade.amount).to eq(0.1 * portfolio_value * fee_multiplier)
          end

          it 'assembles the ETHBTC trade correctly' do
            trade = trades.find { |item| item.symbol == 'ETHBTC' }

            expect(trade.order_side).to eq('SELL')
            expect(trade.amount).to be_within(0.7).percent_of(
              0.1 * portfolio_value / 10.usd * fee_multiplier
            )
          end

          it 'adds the service trade' do
            trade = trades.find { |item| item.symbol == 'BNBETH' }

            expect(trades.size).to be(9)
            expect(trade.order_side).to eq('BUY')
            expect(trade.amount).to eq(
              portfolio_value * 0.1.percent.as_fraction / 2.5.usd
            )
          end
        end
      end
    end
  end
end
