require 'rails_helper'

module AML
  module Checks
    RSpec.describe VerifyName do
      describe '#execute!' do
        context 'given a sanctioned person' do
          let(:first_name) { 'Bashar' }
          let(:last_name) { 'al-Assad' }

          before do
            stub_request_with_recording(
              :get, 'https://www.sanctions.io/search/?sname=Bashar%20al-Assad'
            )
          end

          it 'returns false' do
            result = described_class.execute!(
              first_name: first_name,
              last_name: last_name
            )
            expect(result).to eq(false)
          end

          it 'alerts admin' do
            expect(Alerts::Capture).to receive(:execute!).
              with(hash_including(message: /sanctioned person/))

            described_class.execute!(
              first_name: first_name,
              last_name: last_name
            )
          end
        end

        context 'given a normal person' do
          let(:first_name) { 'John' }
          let(:last_name) { 'Doe' }

          before do
            stub_request_with_recording(
              :get, 'https://www.sanctions.io/search/?sname=John%20Doe'
            )
          end

          it 'returns true' do
            result = described_class.execute!(
              first_name: first_name,
              last_name: last_name
            )
            expect(result).to eq(true)
          end

          it 'does not alert admin' do
            expect(Alerts::Capture).not_to receive(:execute!)
          end
        end
      end
    end
  end
end
