require 'rails_helper'

RSpec.describe 'Admin area' do
  fixtures :currencies, :valuations, :'valuation/readings', :users

  describe 'User Management' do
    it 'works' do
      visit_with_http_basic_auth admin_users_path
      expect(page).to have_text('signed-up@example.com')
    end
  end

  describe 'Currencies Management' do
    it 'works' do
      visit_with_http_basic_auth admin_currencies_path
      expect(page).to have_text('Bitcoin')
    end
  end

  describe 'Valuations Management' do
    let(:timestamp) { Time.parse('Jan 10 2018') }

    before {
      Timecop.travel(timestamp)
      visit_with_http_basic_auth admin_valuations_path
    }

    it 'works' do
      # it "marks rejected currencies with '*'"
      expect(find('table tr#DAO td:nth-of-type(2)')).to have_text('*')

      # it 'marks currencies with valuation readings count'
      btc_reading_count = Currency.btc.valuation_readings.at(timestamp).count
      btc_trusted_reading_count = Currency.btc.valuation_readings.trusted.
        at(timestamp).count

      expect(find('table tr#BTC td:nth-of-type(2)')).
        to have_text("#{btc_trusted_reading_count}(#{btc_reading_count})")

      # it "marks missing valuations of available currencies with '-'"
      expect(find('table tr#BTC td:nth-of-type(2)')).
        to have_text('-')
    end
  end
end
