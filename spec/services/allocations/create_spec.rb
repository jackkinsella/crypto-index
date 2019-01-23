require 'rails_helper'

RSpec.describe Allocations::Create do
  fixtures :indexes, :'index/allocations', :'index/components',
    :'valuation/readings', :valuations

  describe '.execute!' do
    let(:from_date) { Fixtures::UNALLOCATED_TIMESTAMP.to_date }
    let(:to_date) { from_date }
    let(:index) { Index.m10 }

    before {
      Timecop.freeze(Fixtures::UNALLOCATED_TIMESTAMP)
    }

    it 'creates allocations' do
      expect {
        described_class.execute!(
          from_date: from_date,
          to_date: to_date,
          indexes: index
        )
      }.to change {
        Index::Allocation.at(Time.now).count
      }.by(1)
    end
  end
end
