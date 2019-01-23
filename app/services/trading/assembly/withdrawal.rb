module Trading
  module Assembly
    class Withdrawal < ApplicationAction
      def initialize(withdrawal:)
        @withdrawal = withdrawal
      end

      def execute!
        assemble_trades
      end

      private

      attr_reader :withdrawal

      def assemble_trades
        [
          build_service_trade,
          withdrawal.user.holdings.map { |holding|
            amount = holding.size * withdrawal.fraction

            if holding.currency == Currency.btc
              build_trade(
                category: :user,
                base_currency: Currency.eth,
                quote_currency: Currency.btc,
                order_side: 'BUY',
                amount: rounded_amount_for(
                  Currency.eth, Currency.btc,
                  amount / eth_price_in(Currency.btc)
                )
              )
            elsif holding.currency == Currency.eth
              # No trade required
            else
              build_trade(
                category: :user,
                base_currency: holding.currency,
                quote_currency: Currency.eth,
                order_side: 'SELL',
                amount: rounded_amount_for(
                  holding.currency, Currency.eth, amount
                )
              )
            end
          }
        ].flatten.compact.reject { |trade| trade.amount.zero? }
      end

      def build_service_trade
        #
        # TODO: Check fee on Binance and make sure we withdraw the
        # right amount. It should be the size of all liquidated holdings
        # in ETH minus our CryptoIndex fee but no less than that.
        #
        net_amount = 0

        return unless net_amount.positive?

        build_trade(
          category: :service,
          base_currency: Currency.bnb,
          quote_currency: Currency.eth,
          order_side: 'BUY',
          amount: rounded_amount_for(
            Currency.bnb, Currency.eth,
            net_amount * eth_price_in(Currency.bnb)
          )
        )
      end

      def build_trade(attributes = {})
        Market.binance.trades.build(
          attributes.merge(
            initiator: withdrawal,
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

      def eth_price_in(currency)
        Currency.eth.price_usd / currency.price_usd
      end
    end
  end
end
