module Accounts
  module Deposits
    class Relay < ApplicationAction
      AMOUNT_RESERVED_FOR_GAS = 0.0015.eth

      def initialize(deposit:)
        @deposit = deposit
      end

      def execute!
        return if deposit.relayed?

        relayed_amount = deposit.amount - AMOUNT_RESERVED_FOR_GAS

        ApplicationRecord.transaction do
          deposit.create_relayed_transaction!(
            currency: deposit.currency,
            sender: deposit,
            receiver: Market.binance,
            from_address: deposit_address,
            to_address: Market.binance.inbound_address,
            nonce: Blockchains::Ethereum::Network.get_nonce(deposit_address),
            value: relayed_amount
          )

          deposit.relayed_transaction.update!(
            transaction_hash: send_transaction(relayed_amount)
          )

          deposit.update!(relayed_at: Time.now)
        end

        Transactions::ConfirmJob.perform_later(
          transaction: deposit.relayed_transaction
        )
      end

      private

      attr_reader :deposit

      def send_transaction(amount)
        Blockchains::Ethereum::Network.send_transaction(
          private_key: deterministic_wallet.private_key,
          from_address: deposit_address,
          to_address: Market.binance.inbound_address,
          nonce: deposit.relayed_transaction.nonce,
          value: amount
        )
      end

      def deposit_address
        deposit.received_transaction.to_address
      end

      def deterministic_wallet
        @_deterministic_wallet ||=
          Blockchains::DeterministicWallet::Derive.execute!(
            extended_key: Rails.application.credentials.
              blockchains.bip32.master_extended_private_key,
            key_path: deposit_address.key_path.downcase
          )
      end
    end
  end
end
