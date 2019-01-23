module Accounts
  module Deposits
    class RelayJob < ApplicationJob
      def perform(deposit:)
        return if deposit.relayed?

        Relay.execute!(deposit: deposit)
      end
    end
  end
end
