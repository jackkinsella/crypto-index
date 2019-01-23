module Portfolios
  class Update < ApplicationAction
    def initialize(trades:)
      @trades = Array.wrap(trades)
    end

    def execute!
      trades.select { |trade| trade.category?(:user) }.each do |trade|
        Holdings::Update.execute!(
          portfolio: trade.initiator.portfolio,
          currency: trade.from_currency
        )

        Holdings::Update.execute!(
          portfolio: trade.initiator.portfolio,
          currency: trade.to_currency
        )
      end
    end

    private

    attr_reader :trades
  end
end
