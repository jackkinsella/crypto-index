module User::PhoneConfirmation
  extend ActiveSupport::Concern

  VALID_INTERVAL = 1.hour

  included do
    validates :phone_confirmed_at,
      presence: false

    after_save do
      if phone?
        if saved_change_to_phone? && !saved_change_to_phone_confirmed_at?
          send_phone_confirmation_code
        end
      end
    end
  end

  def send_phone_confirmation_code
    touch
    Messaging::SMS::SendJob.set(wait: 1.second).perform_later(
      user: self,
      text: "Your CryptoIndex confirmation code: #{phone_confirmation_code}"
    )
  end

  def phone_confirmed?
    phone_confirmed_at?
  end

  def confirm_phone(code:)
    valid_phone_confirmation_code?(code) &&
    update(phone_confirmed_at: Time.now)
  end

  def confirm_phone!(code:)
    unless valid_phone_confirmation_code?(code)
      raise ConfirmationCodeInvalidError
    end

    raise ConfirmationCodeExpiredError if phone_confirmation_code_expired?

    confirm_phone(code: code) && update!(phone_confirmed_at: Time.now)
  end

  def phone_confirmation_code
    @_phone_confirmation_code ||= Digest::SHA256.new.hexdigest(
      phone_confirmation_secret
    ).tr('a-z', '')[0...4]
  end

  def valid_phone_confirmation_code?(code)
    return false if phone_confirmation_code_expired?
    code == phone_confirmation_code
  end

  class ConfirmationCodeInvalidError < StandardError; end
  class ConfirmationCodeExpiredError < StandardError; end

  private

  def phone_confirmation_code_expired?
    updated_at < VALID_INTERVAL.ago
  end

  def phone_confirmation_secret
    Rails.application.credentials.secret_key_base +
      "/#{id}/#{phone}/#{updated_at.iso8601}"
  end
end
