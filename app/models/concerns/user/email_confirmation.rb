module User::EmailConfirmation
  extend ActiveSupport::Concern

  class_methods do
    def email_confirmation(via:)
      column = via.to_sym

      validates column,
        presence: false

      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def _email_confirmed_at_column
          :#{column}
        end
      RUBY
    end

    def simulate_email_confirmation
      User.new.valid_email_confirmation_token?('-')
    end
  end

  def email_confirmed?
    send :"#{_email_confirmed_at_column}?"
  end

  def confirm_email(token:)
    valid_email_confirmation_token?(token) &&
    update(_email_confirmed_at_column => Time.now)
  end

  def confirm_email!(token:)
    unless valid_email_confirmation_token?(token)
      raise ConfirmationTokenInvalidError
    end

    update!(_email_confirmed_at_column => Time.now)
  end

  def email_confirmation_token
    @_email_confirmation_token ||= Base64.urlsafe_encode64(
      BCrypt::Password.create(email_confirmation_secret)
    )
  end

  def valid_email_confirmation_token?(token)
    hash = Base64.urlsafe_decode64(token) rescue invalid_email_hash
    BCrypt::Password.new(hash) == email_confirmation_secret rescue false
  end

  class ConfirmationTokenInvalidError < StandardError; end

  private

  def email_confirmation_secret
    Rails.application.credentials.secret_key_base +
      "/#{id}/#{email}"
  end

  def invalid_email_hash
    '$2a$10$Y.tF6bOgMVFXtCG6DuIBtuyH6I9LDKZXHJZa.PsuSW2uyMTOclH8.'
  end
end
