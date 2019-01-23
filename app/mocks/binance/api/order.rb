return if Rails.env.production?

module Binance
  module Api
    class Order
      class << self
        def create!(
          symbol: nil, side: nil, type: nil, quantity: nil,
          price: nil, stopPrice: nil, recvWindow: nil,
          newClientOrderId: nil, newOrderResponseType: nil,
          timeInForce: nil, test: false
        )
          # Must be deterministic for tests and fixture builder
          srand symbol.bytes.sum if Rails.env.test?

          raise NotImplementedError unless type == 'MARKET'

          symbol = reverse_map_symbol(symbol)

          {
            symbol: symbol,
            orderId: rand(10**8),
            clientOrderId: newClientOrderId || generate_client_order_id,
            transactTime: (Time.now.to_f * 1_000).to_i,
            price: '0.00000000',
            origQty: '%.8f' % quantity,
            executedQty: '%.8f' % quantity,
            status: 'FILLED',
            timeInForce: timeInForce,
            type: 'MARKET',
            side: side,
            fills: [
              {
                price: '%.8f' % price_for(symbol),
                qty: '%.8f' % quantity,
                commission: '%.8f' % (
                  quantity * commission * price_for("#{base_for(symbol)}BNB")
                ),
                commissionAsset: 'BNB',
                tradeId: rand(10**7)
              }
            ]
          }.tap { |order|
            history[order[:clientOrderId]] = order
          }
        end

        def status!(symbol: nil, originalClientOrderId: nil)
          (
            history[originalClientOrderId] ||
            (raise Binance::Api::Error, 'Order does not exist')
          ).find { |order|
            symbol.nil? || order[:symbol] == symbol
          }
        end

        private

        def generate_client_order_id
          (0...22).map {
            [('0'..'9'), ('A'..'Z'), ('a'..'z')].
              map(&:to_a).flatten[rand(62)]
          }.join
        end

        def commission
          discount_for_using_bnb = 50.percent.as_fraction
          (0.1.percent * (1 - discount_for_using_bnb)).as_fraction
        end

        def price_for(symbol)
          base_currency = Currency.find_by!(symbol: base_for(symbol))
          quote_currency = Currency.find_by!(symbol: quote_for(symbol))

          base_currency.price_usd / quote_currency.price_usd
        end

        def base_for(symbol)
          currency_symbols.find { |currency_symbol|
            symbol.start_with?(currency_symbol)
          }
        end

        def quote_for(symbol)
          currency_symbols.find { |currency_symbol|
            symbol.end_with?(currency_symbol)
          }
        end

        def reverse_map_symbol(symbol)
          case symbol
          when 'BCCBTC' then 'BCHBTC'
          when 'BCCETH' then 'BCHETH'
          when 'IOTABTC' then 'MIOTABTC'
          when 'IOTAETH' then 'MIOTAETH'
          else symbol
          end
        end

        def currency_symbols
          @_currency_symbols ||= Currency.pluck(:symbol)
        end
      end

      class_attribute :history, default: {}, instance_writer: false
    end
  end
end
