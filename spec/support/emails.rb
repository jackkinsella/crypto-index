module Emails
  extend ActiveSupport::Concern

  included do
    before { ActionMailer::Base.deliveries.clear }

    def emails_to(address)
      ActionMailer::Base.deliveries.select { |email|
        email.to.any? { |recipient| recipient == address }
      }
    end

    def last_email
      ActionMailer::Base.deliveries.last
    end

    def links_in_email(email = last_email)
      return nil unless email
      email_body(email).scan(/https?:[^ ]*/).map { |url| to_path(url) }
    end

    def email_body(email = last_email)
      return nil unless email
      email.body.parts.first.decoded
    end
  end

  private

  def to_path(url)
    "#{URI(url).path}?#{URI(url).query}"
  end
end
