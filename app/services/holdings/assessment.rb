module Holdings
  class Assessment < ApplicationService
    def initialize(portfolio:, timestamp:)
      @portfolio = portfolio
      @timestamp = timestamp
    end

    def constituents
      @constituents ||= consolidate(
        [{'ETH' => deposit_net_amount_in_eth}] + trade_results
      )
    end

    %w[USD BTC ETH].each do |in_currency_symbol|
      define_method :"value_#{in_currency_symbol.downcase}" do
        price_method = :"price_#{in_currency_symbol.downcase}_at"
        constituents.reduce(0) do |sum, (symbol, amount)|
          sum + Currency.send(symbol).send(price_method, timestamp) * amount
        end
      end
    end

    private

    attr_reader :portfolio, :timestamp

    def consolidate(adjustments)
      adjustments.each_with_object({}) do |adjustment, memo|
        adjustment.each do |symbol, amount|
          memo[symbol] ||= 0
          memo[symbol] += amount
        end
      end
    end

    def deposit_net_amount_in_eth
      deposits.sum(&:net_amount)
    end

    def trade_results
      #
      # TODO: Add withdrawals
      #
      deposits.map(&:trades).map(&:user).flatten.
        select(&:completed?).map(&:result) +
      rebalancings.map(&:trades).map(&:user).flatten.
        select(&:completed?).map(&:result)
    end

    def deposits
      portfolio.deposits.received_before(timestamp)
    end

    def rebalancings
      portfolio.rebalancings.scheduled_before(timestamp)
    end
  end
end
