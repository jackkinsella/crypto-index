module Trading
  module Orders
    class Create < ApplicationAction
      def initialize(trade:)
        @trade = trade
      end

      def execute!
        return if trade.completed?

        sleep(0.1) and trade.start!

        details =
          if trade.pending? && (status = order_status_for(trade))
            status.merge(
              fills: Binance::Api::Account.trades!(
                symbol: map_symbol(trade.symbol)
              ).select { |trade| trade[:orderId] == status[:orderId] }
            )
          else
            Binance::Api::Order.create!(
              symbol: map_symbol(trade.symbol),
              side: trade.order_side,
              type: trade.order_type,
              quantity: trade.amount,
              newClientOrderId: trade.uid[0...36],
              newOrderResponseType: 'FULL'
            )
          end

        trade.details = details
        trade.attributes = extract_attributes(details)
        trade.complete!

        Portfolios::UpdateJob.perform_later(trades: trade)
      end

      private

      attr_reader :trade

      def order_status_for(trade)
        Binance::Api::Order.status!(
          symbol: map_symbol(trade.symbol),
          originalClientOrderId: trade.uid[0...36]
        )
      rescue Binance::Api::Error => error
        raise unless error.message.match?(/Order does not exist/)
        false
      end

      def map_symbol(symbol)
        case symbol
        when 'BCHBTC' then 'BCCBTC'
        when 'BCHETH' then 'BCCETH'
        when 'MIOTABTC' then 'IOTABTC'
        when 'MIOTAETH' then 'IOTAETH'
        else symbol
        end
      end

      def extract_attributes(data)
        {
          amount: data[:executedQty].to_d,
          price: data[:fills].map { |fill|
            fill[:price].to_d * fill[:qty].to_d
          }.sum / data[:executedQty].to_d
        }.tap { |attributes|
          if data[:fills].pluck(:commissionAsset).uniq.size == 1
            attributes.merge!(
              fee: data[:fills].pluck(:commission).map(&:to_d).sum,
              fee_currency: Currency.find_by!(
                symbol: data[:fills].first[:commissionAsset]
              )
            )
          else
            Alerts::Capture.execute!(
              message: 'Multiple fee currencies detected in a trade',
              details: {
                data: data
              }
            )
          end
        }
      end
    end
  end
end
