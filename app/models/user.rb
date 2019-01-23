class User < ApplicationRecord
  include Encryptable
  include User::Pseudonymization
  include User::Authentication
  include User::EmailConfirmation
  include User::PhoneConfirmation
  include KYC::CountryPolicy

  has_one :account, required: true, dependent: :restrict_with_exception

  has_one :portfolio, required: true, dependent: :restrict_with_exception

  has_one :postal_address, dependent: :restrict_with_exception

  has_one :passport, dependent: :restrict_with_exception

  has_many :addresses,
    class_name: 'Currency::Address', as: :owner,
    inverse_of: :owner, dependent: :nullify

  has_many :deposits,
    class_name: 'User::Account::Deposit', through: :account

  has_many :rebalancings,
    class_name: 'User::Portfolio::Rebalancing', through: :portfolio

  has_many :withdrawals,
    class_name: 'User::Account::Withdrawal', through: :account

  has_many :holdings, through: :portfolio

  email_confirmation via: :email_confirmed_at

  encrypted_attributes :first_name, :last_name

  validates :first_name,
    presence: false

  validates :last_name,
    presence: false

  validates :email,
    presence: true,
    uniqueness: true,
    format: {with: EMAIL_FORMAT}

  validates :phone,
    format: {with: PHONE_FORMAT},
    uniqueness: true,
    allow_nil: true

  validate :email_is_not_disposable, if: :email?

  validate if: :phone? do
    if (number = Phonelib.parse(phone)).possible?
      if number.invalid? || number.possible_types.exclude?(:fixed_or_mobile)
        errors[:phone] << 'must be a mobile number'
      end

      if BLACKLISTED_COUNTRY_CODES.include?(number.country)
        errors[:phone] << "must be outside #{BLACKLISTED_COUNTRIES.to_sentence}"
      end
    end
  end

  delegate :holdings, to: :portfolio

  before_validation do
    build_account if account.nil?
    build_portfolio if portfolio.nil?
  end

  before_validation do
    email&.downcase!
    self.phone = Phonelib.parse(phone).to_s if phone?
  end

  before_validation do
    [:first_name, :last_name].each do |field|
      self[field]&.strip!
      self[field] = nil if field.blank?
    end
  end

  def self.sign_up!(email, ip_address = nil)
    create_with(ip_address: ip_address).
      find_or_create_by!(email: email)
  end

  def postal_address?
    postal_address.present?
  end

  def level_1?
    password? && email_confirmed? && phone_confirmed? && postal_address?
  end

  def sanitized_attributes
    super.merge(
      'email' => email,
      'deposited_at' => deposits.order(:received_at).first&.received_at
    )
  end

  private

  def email_is_not_disposable
    return if email.ends_with?('example.com') # for tests
    return if MailChecker.valid?(email)

    errors[:email] << 'must not be a disposable email address'
  end
end
