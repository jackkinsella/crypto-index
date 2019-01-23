ENV['RAILS_ENV'] ||= 'test'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_filter 'mocks'
    add_group 'Services', 'app/services'
    add_group 'Validators', 'app/validators'
  end
end

require File.expand_path('../../config/environment', __FILE__)

if Rails.env.production?
  abort('The Rails environment is running in production mode!')
end

require 'spec_helper'
require 'rspec/rails'
require 'webmock/rspec'

Dir[
  "#{Rails.root}/spec/support/**/*.rb",
  "#{Rails.root}/spec/system/contexts/**/*.rb"
].reject { |file| file.match(/fixture_builder/) }.
  each { |file| require file }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include(Fixtures)
  config.include(SystemTests)
  config.include(Recordings)
  config.include(Timing)
  config.include(Emails)
  config.include(SMS)
  config.include(IPAddress)
  config.include(Blockchains::Mining)
  config.include(Blockchains::Accounts)

  config.before(:all) do
    Valuation::Indicator.refresh
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  config.after do
    Timecop.return
  end

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
