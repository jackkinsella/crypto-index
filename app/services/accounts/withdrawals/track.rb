module Accounts
  module Withdrawals
    class Track < ApplicationAction
      def initialize
        @addresses = Currency::Address.withdrawal.to_a
      end

      def execute!
        list_transactions.each do |data|
          track_withdrawal_for!(data)
        end
      end

      private

      attr_reader :addresses

      def list_transactions
        Blockchains::Ethereum::Network.list_transactions(
          addresses: addresses
        )
      end

      def track_withdrawal_for!(data)
        return if Currency.eth.transactions.exists?(
          transaction_hash: data[:transaction_hash]
        )

        # TODO: Implement the relay of withdrawals:
        #
        # After a withdrawal is REQUESTED and subsequently CONFIRMED by a user,
        # we currently require it to be manually ARRANGED on Binance: This means
        # that we manually call `Trading::Assembly::Withdrawal`.
        # We then generate a `withdrawal` address for the user account
        # and send the ETH amount to that `withdrawal` address.
        # The next step is for this action to track the COLLECTED
        # transaction and then RELEASE it to the user's inbound address.
        # Afterwards, the withdrawal can be marked FINALIZED.
        #
        raise NotImplementedError
      end
    end
  end
end
