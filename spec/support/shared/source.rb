require 'rails_helper'

RSpec.shared_examples 'Source' do
  it 'is explicit about which currencies it supports' do
    expect(described_class::SUPPORTS.keys).to match_array(
      CSV.read_config_data(:currencies).by_col[0].map(&:to_sym)
    )
  end
end
