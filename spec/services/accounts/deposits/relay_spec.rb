require 'rails_helper'

module Accounts
  module Deposits
    RSpec.describe Relay do
      fixtures :currencies, :markets, :users, :'user/accounts'

      describe 'idempotency', :ethereum do
        #
        # TODO: Remove all/most of this boilerplate setup once a
        # comprehensive set of fixtures is available.
        #
        let(:user) { User.last }
        let(:currency) { Currency.eth }
        let(:value) { 1.0.eth }

        let!(:from_address) {
          Currency::Address.create!(
            value: ethereum_accounts.visitor.address,
            category: :user_outbound,
            owner: user,
            currency: currency
          )
        }

        let!(:to_address) {
          Currency::Address.create!(
            value: '0x4E940397E198d10F92D18305E8fd37005C7A6041',
            category: :deposit,
            owner: user.account,
            key_path: 'm/60/3',
            currency: currency
          )
        }

        let!(:transaction) {
          Currency::Transaction.create!(
            from_address: from_address,
            to_address: to_address,
            nonce: 0,
            sender: user,
            receiver: deposit,
            currency: currency,
            value: value
          )
        }

        let!(:deposit) {
          User::Account::Deposit.create!(
            received_at: Time.now,
            currency: currency,
            amount: value,
            crypto_index_fee: 0.001.eth,
            user_account: user.account
          )
        }

        context 'with no internal failures' do
          it 'sends only one transaction' do
            expect(Blockchains::Ethereum::Network).to(
              receive(:send_transaction).once
            )

            2.times do
              described_class.execute!(deposit: deposit)
            end

            expect(1).to be(1)
          end
        end

        context 'when `relayed_at` fails to be set' do
          it 'sends only one transaction' do
            expect(Blockchains::Ethereum::Network).to(
              receive(:send_transaction).once
            )

            described_class.execute!(deposit: deposit)
            deposit.update!(relayed_at: nil)

            expect { described_class.execute!(deposit: deposit) }.to(
              raise_error(ActiveRecord::RecordNotSaved)
            )
          end
        end

        context 'when `send_transaction` fails' do
          it 'will attempt to send again, using the same nonce' do
            call_count = 0

            allow(
              Blockchains::Ethereum::Network
            ).to receive(:send_transaction) do
              call_count += 1

              raise IOError, 'Transient Ethereum failure' if call_count == 1

              '0x2b3a169c62dd5b2f41621f02396f82a' \
              'da5a0715d7a258bbe27e966092b50d679'
            end

            expect(Blockchains::Ethereum::Network).to(
              receive(:send_transaction).with(hash_including(nonce: 0)).twice
            )

            2.times {
              begin
                described_class.execute!(deposit: deposit)
              rescue IOError
                next
              end
            }
          end
        end
      end
    end
  end
end
