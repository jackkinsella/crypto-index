module Accounts
  module Deposits
    class Finalize < ApplicationAction
      def initialize(deposits:)
        @deposits = Array.wrap(deposits)
      end

      def execute!
        deposits.each do |deposit|
          finalize(deposit)
        end
      end

      private

      attr_reader :deposits

      def finalize(deposit)
        return unless deposit.realized? && !deposit.finalized?

        finalized_at = deposit.trades.maximum(:completed_at)

        deposit.update!(
          crypto_index_fee: deposit.trades.service.sum(:amount),
          finalized_at: finalized_at
        )

        UserMailer.portfolio_ready(deposit.portfolio).deliver_later

        assessment = Holdings::Assessment.new(
          portfolio: deposit.user.portfolio, timestamp: finalized_at
        )
      end
    end
  end
end
