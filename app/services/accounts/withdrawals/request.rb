module Accounts
  module Withdrawals
    class Request < ApplicationAction
      def initialize(
        account:, fraction: 100.percent.as_fraction, currency: Currency.eth
      )
        @account = account
        @fraction = fraction
        @currency = currency
      end

      def execute!
        # TODO: Refactor
        return if account.withdrawals.not_finalized.exists?

        withdrawal = account.withdrawals.create!(
          currency: currency,
          fraction: fraction,
          requested_at: Time.now
        )

        UserMailer.withdrawal_requested(withdrawal).deliver_later
      end

      private

      attr_reader :account, :fraction, :currency
    end
  end
end
