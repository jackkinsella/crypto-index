require 'rails_helper'

module Blockchains
  module Ethereum
    RSpec.describe Network, :ethereum do
      let(:from_address) { ethereum_accounts.visitor.address }
      let(:to_address) { ethereum_accounts.binance_inbound.address }

      let(:transaction_arguments) {
        {
          private_key: ethereum_accounts.visitor.private_key,
          from_address: from_address,
          to_address: to_address,
          nonce: 0,
          value: 2.1.to_d
        }
      }

      describe '#get_balances' do
        let(:address) { from_address }

        it 'gives the ETH balance of every address' do
          expect(
            subject.get_balances(addresses: [address])[address.downcase]
          ).to be > 1_000
        end
      end

      describe '#transaction_details' do
        let(:address) { from_address }

        let(:transaction_hash) {
          subject.send_transaction(**transaction_arguments).tap { mine }
        }

        it 'returns details for the transaction' do
          expect(
            subject.transaction_details(
              transaction_hash: transaction_hash
            )[:block_hash]
          ).to be_present
        end
      end

      describe '#send_transaction' do
        let(:first_user) { ethereum_accounts.visitor }
        let(:binance_address) { ethereum_accounts.binance_inbound.address }

        let(:transaction_arguments) {
          {
            private_key: first_user.private_key,
            from_address: first_user.address,
            to_address: binance_address,
            nonce: 0,
            value: 100.0
          }
        }

        it 'returns the transaction hash when given valid arguments' do
          expect(subject.send_transaction(**transaction_arguments)).
            to match(/0x[0-9a-f]+/)
        end

        it 'throws an exception if the `from_address` does not match' \
        'the private_key' do
          inconsistent_transaction_arguments = transaction_arguments.merge(
            from_address: ethereum_accounts.signed_up.address
          )
          expect {
            subject.send_transaction(**inconsistent_transaction_arguments)
          }.to raise_error(ArgumentError)
        end
      end

      describe '#list_transactions' do
        it 'shows a transaction that has just been mined' do
          expect(
            subject.list_transactions(
              addresses: to_address, direction: :IN
            ).size
          ).to eq(0)

          subject.send_transaction(**transaction_arguments)
          mine

          expect(
            subject.list_transactions(
              addresses: to_address, direction: :IN
            ).size
          ).to eq(1)
        end
      end
    end
  end
end
