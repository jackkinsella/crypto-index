module User::Authentication
  extend ActiveSupport::Concern

  MINIMUM_PASSWORD_LENGTH = 8

  included do
    has_secure_password validations: false

    has_many :sessions, dependent: :nullify

    validates :password,
      length: {minimum: MINIMUM_PASSWORD_LENGTH},
      allow_nil: true
  end

  class_methods do
    def simulate_authentication
      User.new(password: '-').authenticate(SecureRandom.alphanumeric)
    end
  end

  def password?
    password_digest.present?
  end

  def update_password!(new_password:, old_password: nil)
    # TODO: Implement password change (require old password in this case)
    return if password? && old_password.nil?
    update!(password: new_password)
  end

  def log_in!
    session = sessions.create!
    session.token
  end

  def log_out!(token:)
    session = sessions.find_by!(token: token)
    session.destroy!
  end
end
