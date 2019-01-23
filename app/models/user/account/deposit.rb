class User::Account::Deposit < ApplicationRecord
  MINIMUM_AMOUNT = 1.eth
  MAXIMUM_AMOUNT_LEVEL_1 = 10.eth
  MAXIMUM_AMOUNT_LEVEL_2 = 5_000.eth
  MAXIMUM_AMOUNT_LEVEL_3 = Float::INFINITY.eth

  self.table_name = 'user/account/deposits'

  belongs_to :user_account,
    class_name: 'User::Account', foreign_key: :account_id,
    inverse_of: :deposits

  belongs_to :currency

  has_one :received_transaction,
    class_name: 'Currency::Transaction', as: :receiver,
    inverse_of: false, dependent: :restrict_with_exception

  has_one :relayed_transaction,
    class_name: 'Currency::Transaction', as: :sender,
    inverse_of: false, dependent: :restrict_with_exception

  has_many :trades,
    class_name: 'Market::Trade', as: :initiator,
    inverse_of: :initiator, dependent: :restrict_with_exception

  validates :amount,
    numericality: {
      greater_than: 0
    }

  validates :crypto_index_fee,
    numericality: {
      greater_than_or_equal_to: 0
    },
    allow_nil: true

  validates :received_at,
    presence: true

  validates :relayed_at,
    presence: false

  validates :finalized_at,
    presence: false

  alias_attribute :account, :user_account

  delegate :user, to: :user_account

  delegate :portfolio, to: :user

  scope :received_before, ->(time) { where('received_at <= ?', time) }
  scope :received_after, ->(time) { where('received_at > ?', time) }

  scope :finalized, -> { where.not(finalized_at: nil) }
  scope :not_finalized, -> { where(finalized_at: nil) }

  def net_amount
    amount - crypto_index_fee_eth
  end

  def value_usd
    amount * currency.price_usd_at(received_at)
  end

  def net_value_usd
    net_amount * currency.price_usd_at(received_at)
  end

  def crypto_index_fee_eth
    # TODO: It is currently too easy to confuse fee currencies
    trades.service.where(symbol: 'BNBETH').sum(&:cost)
  end

  def crypto_index_fee_currency
    Currency.bnb # TODO: This will be extended once we add more markets
  end

  def relayed?
    relayed_at?
  end

  def realized?
    trades.exists? && trades.all?(&:completed?)
  end

  def finalized?
    finalized_at?
  end

  def external_id
    @_external_id ||= Digest::SHA256.new.hexdigest(
      {
        type: :deposit,
        id: id,
        account_id: user_account.id,
        currency_id: currency.id,
        amount: amount
      }.to_json
    )
  end
end
