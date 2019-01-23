class ApplicationJob < ActiveJob::Base
  include Rails.application.routes.url_helpers

  class << self
    def default_url_options
      Rails.application.config.action_mailer.default_url_options
    end
  end
end
