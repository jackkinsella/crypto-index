class User::Account::Withdrawal < ApplicationRecord
  include User::EmailConfirmation

  self.table_name = 'user/account/withdrawals'

  belongs_to :user_account,
    class_name: 'User::Account', foreign_key: :account_id,
    inverse_of: :withdrawals

  belongs_to :currency

  has_one :collected_transaction,
    class_name: 'Currency::Transaction', as: :receiver,
    inverse_of: false, dependent: :restrict_with_exception

  has_one :released_transaction,
    class_name: 'Currency::Transaction', as: :sender,
    inverse_of: false, dependent: :restrict_with_exception

  has_many :trades,
    class_name: 'Market::Trade', as: :initiator,
    inverse_of: :initiator, dependent: :restrict_with_exception

  email_confirmation via: :confirmed_by_email_at

  validates :fraction,
    numericality: {
      greater_than: 0,
      less_than_or_equal_to: 1
    }

  validates :amount,
    numericality: {
      greater_than: 0
    },
    allow_nil: true

  validates :crypto_index_fee,
    numericality: {
      greater_than_or_equal_to: 0
    },
    allow_nil: true

  validates :requested_at,
    presence: true

  validates :arranged_at,
    presence: false

  validates :collected_at,
    presence: false

  validates :released_at,
    presence: false

  validates :finalized_at,
    presence: false

  delegate :user, to: :user_account

  delegate :portfolio, :email, to: :user

  scope :finalized, -> { where.not(finalized_at: nil) }
  scope :not_finalized, -> { where(finalized_at: nil) }

  def crypto_index_fee_currency
    Currency.bnb # TODO: Check `Assembly::Withdrawal#build_service_trade`
  end

  def arranged?
    arranged_at?
  end

  def collected?
    collected_at?
  end

  def released?
    released_at?
  end

  def finalized?
    finalized_at?
  end

  def net_amount
    amount - crypto_index_fee
  end

  def external_id
    @_external_id ||= Digest::SHA256.new.hexdigest(
      {
        type: :withdrawal,
        id: id,
        account_id: user_account.id,
        currency_id: currency.id,
        amount: amount
      }.to_json
    )
  end
end
