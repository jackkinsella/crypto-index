module Trading
  module Assembly
    class Deposit < ApplicationAction
      def initialize(deposit:, index:)
        @deposit = deposit
        @index = index # TODO: Should not depend on index?
      end

      def execute!
        assemble_trades
      end

      private

      attr_reader :deposit, :index

      def assemble_trades
        net_amount = deposit.amount - crypto_index_fee

        [
          build_service_trade,
          components_without_eth.map { |component|
            weighted_amount_in_eth = net_amount * component.weight

            if component.currency == Currency.btc
              build_trade(
                category: :user,
                base_currency: Currency.eth,
                quote_currency: Currency.btc,
                order_side: 'SELL',
                amount: rounded_amount_for(
                  Currency.eth, Currency.btc,
                  weighted_amount_in_eth
                )
              )
            else
              build_trade(
                category: :user,
                base_currency: component.currency,
                quote_currency: Currency.eth,
                order_side: 'BUY',
                amount: rounded_amount_for(
                  component.currency, Currency.eth,
                  weighted_amount_in_eth * eth_price_in(component.currency)
                )
              )
            end
          }
        ].flatten.compact.reject { |trade| trade.amount.zero? }
      end

      def build_service_trade
        #
        # TODO: The correctness of this still needs to be tested.
        #

        net_amount = crypto_index_fee -
          Accounts::Deposits::Relay::AMOUNT_RESERVED_FOR_GAS

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
            initiator: deposit,
            order_type: 'MARKET'
          )
        )
      end

      def crypto_index_fee
        CryptoIndex::Fee.for_deposit_of(deposit.amount)
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

      def eth_component
        index.components.find { |component|
          component.currency == Currency.eth
        }
      end

      def components_without_eth
        index.components.order(:currency_id).reject { |component|
          component.currency == Currency.eth
        }
      end

      def eth_price_in(currency)
        Currency.eth.price_usd / currency.price_usd
      end
    end
  end
end
