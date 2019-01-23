module SystemTests
  extend ActiveSupport::Concern
  include ActiveJob::TestHelper
  include Authentication

  included do
    before(:all, type: :system) do
      logging_dev = Rails.root.join('tmp/logging-dev.txt').exist?
      Capybara.server = :puma, {Silent: !logging_dev}
      Capybara.server_host = 'localhost'
    end

    before(:each, type: :system) do |example|
      driven_by :selenium_chrome_headless
      Capybara.current_session.current_window.resize_to(1_400, 1_024)
    end

    around(:each, type: :system) do |example|
      perform_enqueued_jobs {
        example.run_with_retry(
          exceptions_to_retry: [Net::ReadTimeout],
          retry: 3
        )
      }
    end

    after(:each, type: :system) do |example|
      unless Capybara.current_driver == :rack_test
        ignore_js_error = example.metadata[:ignore_js_error]

        # TODO: Check if the CSP errors in the test environment can be fixed
        javascript_errors = page.driver.browser.manage.logs.get(:browser).
          select { |log| log.level == 'SEVERE' }.map(&:message).
          reject { |error| error.match(/ "Warning:/) }.
          reject { |error| error.match(/Refused to execute inline script/) }.
          reject { |error| ignore_js_error && error.match(ignore_js_error) }.
          join("\n")

        expect(javascript_errors).to be_empty,
          "expected no javascript errors, got:\n\n#{javascript_errors}"
      end
    end
  end
end
