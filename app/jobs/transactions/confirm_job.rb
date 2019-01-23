#
# TODO: Refactor and extract parts into `Transactions::Confirm` action
#
module Transactions
  class ConfirmJob < ApplicationJob
    MINIMUM_NUMBER_OF_CONFIRMATIONS = Rails.env.production? ? 30 : 3
    RETRY_INTERVAL = 10.seconds

    def perform(transaction:)
      @transaction = transaction

      return if transaction.confirmed?

      unless number_of_confirmations_reached?(transaction)
        retry_job(wait: RETRY_INTERVAL) and return
      end

      data = transaction_details(transaction)

      transaction.update!(
        confirmed_at: Time.now,
        fee: data[:fee],
        timestamp: data[:timestamp],
        details: data
      )
    end

    after_perform do |job|
      @transaction = job.arguments.first[:transaction]

      if transaction.confirmed?
        if deposit_received?
          UserMailer.deposit_received(transaction.receiver).deliver_later
          relay_deposit(transaction)
        elsif deposit_relayed?
          realize_deposit(transaction)
        end
      end
    end

    private

    attr_reader :transaction

    def deposit_received?
      transaction.receiver_type == 'User::Account::Deposit'
    end

    def deposit_relayed?
      transaction.sender_type == 'User::Account::Deposit' &&
      transaction.receiver_type == 'Market'
    end

    def relay_deposit(transaction)
      Accounts::Deposits::RelayJob.perform_later(
        deposit: transaction.receiver
      )
    end

    def realize_deposit(transaction)
      Accounts::Deposits::RealizeJob.perform_later(
        deposit: transaction.sender
      )
    end

    def number_of_confirmations_reached?(transaction)
      Blockchains::Ethereum::Network.number_of_confirmations(
        transaction_hash: transaction.transaction_hash
      ) >= MINIMUM_NUMBER_OF_CONFIRMATIONS
    end

    def transaction_details(transaction)
      Blockchains::Ethereum::Network.transaction_details(
        transaction_hash: transaction.transaction_hash
      )
    end
  end
end
