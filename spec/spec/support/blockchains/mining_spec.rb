require 'rails_helper'

module Blockchains
  module Mining
    RSpec.describe Ganache, :ethereum do
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

      describe '#mine' do
        it 'moves the current block number forward' do
          expect { subject.mine(1) }.to change {
            subject.current_block_number
          }.by(1)
        end
      end

      describe 'reverting' do
        def assert_balance_is_zero
          expect(
            subject.get_balances(addresses: [to_address])[to_address.downcase]
          ).to eq(0)
        end

        def assert_balance_is_non_zero
          expect(
            subject.get_balances(addresses: [to_address])[to_address.downcase]
          ).to be >= 2.to_d
        end

        it 'restores the prior blockchain state' do
          assert_balance_is_zero

          snapshot_id = subject.take_snapshot

          subject.send_transaction(**transaction_arguments) and mine
          assert_balance_is_non_zero

          subject.revert_to_snapshot(snapshot_id)
          assert_balance_is_zero
        end
      end
    end
  end
end
