module Accounts
  module Deposits
    class Track < ApplicationAction
      def initialize
        @addresses = Currency::Address.deposit.to_a
      end

      def execute!
        list_transactions.each do |data|
          track_deposit_for!(data)
        end
      end

      private

      attr_reader :addresses

      def list_transactions
        Blockchains::Ethereum::Network.list_transactions(
          addresses: addresses
        )
      end

      def track_deposit_for!(data)
        return if Currency.eth.transactions.exists?(
          transaction_hash: data[:transaction_hash]
        )

        if deposit_inadmissible?(data)
          capture_alert(data)
          return
        end

        to_address = to_address_for(data)
        user = to_address.user

        received_transaction = ApplicationRecord.transaction {
          from_address = create_from_address_for!(data, user)
          deposit = create_deposit_for!(data, user)

          create_transaction_for!(
            data, deposit, from_address, to_address
          )
        }

        Transactions::ConfirmJob.perform_later(
          transaction: received_transaction
        )
      end

      def to_address_for(data)
        Currency.eth.addresses.find_by!(value: data[:to_address])
      end

      def create_from_address_for!(data, user)
        Currency::Address.create_with(
          owner: user,
          currency: Currency.eth,
          category: :user_outbound
        ).find_or_create_by!(
          value: data[:from_address]
        )
      end

      def create_deposit_for!(data, user)
        user.account.deposits.create!(
          currency: Currency.eth,
          amount: data[:value],
          received_at: Time.now
        )
      end

      def create_transaction_for!(data, deposit, from_address, to_address)
        Currency.eth.transactions.create!(
          sender: to_address.user,
          receiver: deposit,
          from_address: from_address,
          to_address: to_address,
          nonce: data[:nonce],
          value: data[:value],
          transaction_hash: data[:transaction_hash]
        )
      end

      def deposit_inadmissible?(data)
        # TODO: Track cumulative violations of the maximum amount
        data[:value] < User::Account::Deposit::MINIMUM_AMOUNT ||
        data[:value] > User::Account::Deposit::MAXIMUM_AMOUNT_LEVEL_1
      end

      def capture_alert(data)
        Alerts::Capture.execute!(
          message: 'A deposit is violating the minimum/maximum amounts',
          details: {
            transaction_hash: data[:transaction_hash],
            value: data[:value],
            currency: 'ETH'
          },
          throttle_for: 1.day
        )
      end
    end
  end
end
