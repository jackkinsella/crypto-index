module Accounts
  module Deposits
    class Realize < ApplicationAction
      def initialize(deposit:)
        @deposit = deposit
      end

      def execute!
        # FIXME: raise NotImplementedError if Index.count > 1

        trades = Trading::Assembly::Deposit.execute!(
          deposit: deposit, index: Index.m10
        )

        ApplicationRecord.transaction do
          trades.each(&:save!)
        end

        trades.each do |trade|
          Trading::Orders::CreateJob.perform_later(trade: trade)
        end
      end

      private

      attr_reader :deposit
    end
  end
end
