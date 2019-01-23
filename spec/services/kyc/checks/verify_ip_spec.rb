require 'rails_helper'

module KYC
  module Checks
    RSpec.describe VerifyIP do
      fixtures :users

      describe '#execute!' do
        let(:us_ip_address) { '184.172.238.18' }
        let(:german_ip_address) { '178.12.238.169' }

        context 'when the ip address is for an allowed country' do
          it 'returns true' do
            expect(
              described_class.execute!(ip_address: german_ip_address)
            ).to eq(true)
          end
        end

        context 'when the ip address is for a banned country' do
          it 'returns false' do
            expect(
              described_class.execute!(ip_address: us_ip_address)
            ).to eq(false)
          end
        end

        context 'when the ip address is used by many other users' do
          before do
            stub_const(
              "#{described_class}::THRESHOLD_FOR_SUSPICIOUS_IP_USAGE", 1
            )
            users(:signed_up).update!(
              created_at: 5.days.ago,
              ip_address: german_ip_address
            )
          end

          it 'returns false' do
            expect(
              described_class.execute!(ip_address: german_ip_address)
            ).to eq(false)
          end
        end
      end
    end
  end
end
