module IPAddress
  extend ActiveSupport::Concern

  included do
    around(:example, :ip_address) do |example|
      original_app = Capybara.app

      Capybara.app = ->(env) {
        Rails.application.call(
          env.merge('REMOTE_ADDR' => example.metadata[:ip_address])
        )
      }

      example.run

      Capybara.app = original_app
    end
  end
end
