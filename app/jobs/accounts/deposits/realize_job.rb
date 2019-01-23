module Accounts
  module Deposits
    class RealizeJob < ApplicationJob
      def perform(deposit:)
        return if deposit.realized?

        Realize.execute!(deposit: deposit)
      end
    end
  end
end
