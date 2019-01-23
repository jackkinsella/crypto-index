require 'rails_helper'

RSpec.describe 'Transaction reports' do
  fixtures :all

  # FIXME: This test is incomplete until such point as we witch to
  # users(:withdrew) once it's available with fixture data.
  #
  let(:user) { users(:rebalanced) }
  let(:download_dir) { Rails.root.join('tmp/downloads') }
  let(:spreadsheet) {
    File.join(download_dir, Reports::Accounts::Transactions::FILE_NAME)
  }

  before {
    # TODO: Switch back to chrome_headless once the bug in the chrome_headless
    # source that is breaking downloads has been fixed. At this point the
    # :ignore_js_error tag below can likely be removed too.
    chrome_profile = Selenium::WebDriver::Chrome::Profile.new
    chrome_profile['download.default_directory'] = download_dir
    driven_by :selenium, using: :chrome, options: {profile: chrome_profile}
  }

  after {
    FileUtils.rm_rf(download_dir, secure: true)
  }

  it 'generates a downloadable spreadsheet',
    ignore_js_error: /chrome-search/ do
    log_in(user: user)
    click_on 'Report' and wait
    expect(File.exist?(spreadsheet)).to be true
  end
end
