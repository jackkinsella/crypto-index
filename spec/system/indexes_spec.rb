require 'rails_helper'

RSpec.describe 'Indexes' do
  fixtures :currencies, :indexes, :'index/allocations',
    :'index/components', :valuations

  let(:index) { Index.market10 }

  before {
    Timecop.freeze(Fixtures::DEFAULT_TIMESTAMP)
  }

  it 'works' do
    visit indexes_path
    click_link 'Market10'

    # FIXME: This text should be visible but Selenium thinks otherwise. This
    # could also mean Googlebot will have issues scraping our content.
    index_value = find('h2.subtitle', visible: false).text.extract_d

    # Note: The exact algorithm for value is tested in Index::Allocation
    expect(index_value.round).to be > 100

    within('table') do
      btc_percent = find('tr#BTC td:nth-of-type(5)').text.extract_d
      expected_btc_percent =
        index.components.where(currency: Currency.btc).take.weight * 100

      expect(btc_percent).to be > 0
      expect(btc_percent).to eq(expected_btc_percent)

      btc_market_cap = find('tr#BTC td:nth-of-type(3)').text.extract_d
      expected_btc_market_cap =
        Currency.btc.valuations.at(Time.now).take.market_cap_usd.round

      expect(btc_market_cap).to be > 0
      expect(btc_market_cap).to eq(expected_btc_market_cap)
    end
  end
end
