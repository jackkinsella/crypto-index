module Portfolios
  module Rebalancings
    class Finalize < ApplicationAction
      def initialize(rebalancings:)
        @rebalancings = Array.wrap(rebalancings)
      end

      def execute!
        rebalancings.each do |rebalancing|
          finalize(rebalancing)
        end
      end

      private

      attr_reader :rebalancings

      def finalize(rebalancing)
        return unless rebalancing.realized? && !rebalancing.finalized?

        finalized_at = rebalancing.trades.maximum(:completed_at)

        rebalancing.update!(
          crypto_index_fee: rebalancing.trades.service.sum(:amount),
          finalized_at: finalized_at
        )

        UserMailer.portfolio_rebalanced(rebalancing).deliver_later

        assessment = Holdings::Assessment.new(
          portfolio: rebalancing.user.portfolio, timestamp: finalized_at
        )
      end
    end
  end
end
