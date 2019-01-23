require 'rails_helper'

module KYC
  module Checks
    RSpec.describe VerifyNationalIdentity do
      describe '#execute!' do
        let(:identity_number) { '071047590' }

        context 'when valid checkum given' do
          let(:checksum) { '3' }
          it 'returns true' do
            result = described_class.execute!(
              machine_readable_zone: "#{identity_number}#{checksum}"
            )
            expect(result).to be true
          end
        end

        context 'when invalid checkum given' do
          let(:checksum) { '5' }
          it 'returns false' do
            result = described_class.execute!(
              machine_readable_zone: "#{identity_number}#{checksum}"
            )
            expect(result).to be false
          end
        end
      end
    end
  end
end
