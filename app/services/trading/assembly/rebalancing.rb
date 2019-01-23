module Trading
  module Assembly
    class Rebalancing < ApplicationAction
      def initialize(rebalancing:)
        @rebalancing = rebalancing
        @portfolio = rebalancing.user_portfolio
      end

      def execute!
        assemble_trades
      end

      private

      attr_reader :rebalancing, :portfolio

      def assemble_trades
        # FIXME: raise NotImplementedError if Index.count > 1

        eth_difference = differences['ETH'] +
          CryptoIndex::Fee.for_rebalancing_of(portfolio.value_usd) /
          Currency.eth.price_usd

        (
          differences.except('BTC', 'ETH').map { |symbol, amount|
            trade_and_eth_amount_for(
              Currency.send(symbol), Currency.eth, amount
            ).tap { |_trade, eth_amount|
              eth_difference += eth_amount
            }.first
          } + [
            trade_and_eth_amount_for(
              Currency.eth, Currency.btc, eth_difference
            ).first
          ] + [
            build_service_trade
          ]
        ).compact.reject { |trade| trade.amount.zero? }
      end

      def trade_and_eth_amount_for(base_currency, quote_currency, amount)
        rounded_amount = rounded_amount_for(
          base_currency, quote_currency, amount.abs
        )

        return [nil, 0] if rounded_amount.zero?

        eth_amount =
          (amount <=> 0) * rounded_amount / eth_price_in(base_currency)

        [
          build_trade(
            category: :user,
            base_currency: base_currency,
            quote_currency: quote_currency,
            order_side: amount.positive? ? 'BUY' : 'SELL',
            amount: rounded_amount
          ),
          eth_amount
        ]
      end

      def build_service_trade
        fee_amount =
          CryptoIndex::Fee.for_rebalancing_of(portfolio.value_usd) /
          Currency.bnb.price_usd

        return unless fee_amount.positive?

        build_trade(
          category: :service,
          base_currency: Currency.bnb,
          quote_currency: Currency.eth,
          order_side: 'BUY',
          amount: rounded_amount_for(
            Currency.bnb, Currency.eth, fee_amount
          )
        )
      end

      def build_trade(attributes = {})
        Market.binance.trades.build(
          attributes.merge(
            initiator: rebalancing,
            order_type: 'MARKET'
          )
        )
      end

      def rounded_amount_for(base_currency, quote_currency, amount)
        trade_filters = trade_filters_for(base_currency, quote_currency)
        (amount / trade_filters[:step_size]).floor * trade_filters[:step_size]
      end

      def trade_filters_for(base_currency, quote_currency)
        Market.binance.trade_filters_for(
          "#{base_currency}#{quote_currency}".yield_self { |symbol|
            case symbol
            when 'BCHBTC' then 'BCCBTC'
            when 'BCHETH' then 'BCCETH'
            when 'MIOTABTC' then 'IOTABTC'
            when 'MIOTAETH' then 'IOTAETH'
            else symbol
            end
          }
        )
      end

      def differences
        @_differences ||= begin
          new_portfolio_value_usd = portfolio.value_usd -
            CryptoIndex::Fee.for_rebalancing_of(portfolio.value_usd)

          differences_between(
            portfolio.constituent_weights,
            Index.m10.current_allocation.to_h
          ).map { |symbol, weight|
            [
              symbol,
              weight * new_portfolio_value_usd /
                Currency.send(symbol).price_usd
            ]
          }.to_h
        end
      end

      def differences_between(allocation_1, allocation_2)
        allocation_1.merge(allocation_2).reduce({}) do |memo, (symbol, _)|
          memo.merge(
            symbol => (allocation_2[symbol] || 0) - (allocation_1[symbol] || 0)
          )
        end
      end

      def eth_price_in(currency)
        Currency.eth.price_usd / currency.price_usd
      end
    end
  end
end
