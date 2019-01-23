module Accounts
  module Deposits
    class FinalizeJob < ApplicationJob
      def perform
        deposits = User::Account::Deposit.not_finalized.select(&:realized?)

        Finalize.execute!(deposits: deposits)
      end
    end
  end
end
