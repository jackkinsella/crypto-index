class Currency::Transaction < ApplicationRecord
  BITCOIN_FORMAT = nil # TODO
  ETHEREUM_FORMAT = /\A0x[0-9A-Fa-f]{64}\z/

  self.table_name = 'currency/transactions'

  belongs_to :currency

  belongs_to :sender, polymorphic: true

  belongs_to :receiver, polymorphic: true

  belongs_to :from_address,
    class_name: 'Currency::Address', inverse_of: :outgoing_transactions

  belongs_to :to_address,
    class_name: 'Currency::Address', inverse_of: :incoming_transactions

  validates :sender_type,
    inclusion: {
      in: [
        'Market', 'User', 'User::Account::Deposit', 'User::Account::Withdrawal'
      ]
    }

  validates :receiver_type,
    inclusion: {
      in: [
        'Market', 'User', 'User::Account::Deposit', 'User::Account::Withdrawal'
      ]
    }

  validates :value,
    numericality: {
      greater_than: 0
    }

  validates :fee,
    numericality: {
      greater_than_or_equal_to: 0
    },
    allow_nil: true

  validates :transaction_hash,
    presence: false

  validates :details,
    presence: false

  validates :timestamp,
    presence: false

  validates :confirmed_at,
    presence: false

  validates :nonce,
    presence: true,
    uniqueness: {scope: :from_address_id},
    numericality: {
      greater_than_or_equal_to: 0
    }

  validate :transaction_hash_has_valid_format

  def on_chain?
    transaction_hash?
  end

  def in_progress?
    on_chain && !confirmed?
  end

  def confirmed?
    confirmed_at?
  end

  def confirmed_at_in_words
    time_ago_in_words(confirmed_at || created_at) # FIXME
  end

  def bitcoin?
    currency == Currency.btc
  end

  def ethereum?
    currency == Currency.eth
  end

  def sanitized_attributes
    super.merge(
      'transaction_hash' => transaction_hash,
      'from_address' => from_address,
      'to_address' => to_address,
      'value' => value,
      'timestamp' => timestamp,
      'confirmed_at' => confirmed_at,
      'confirmed_at_in_words' => confirmed_at_in_words
    )
  end

  private

  def transaction_hash_has_valid_format
    return if transaction_hash.nil? || transaction_hash.match?(hash_format)
    errors[:transaction_hash] << 'is invalid'
  end

  def hash_format
    (ethereum? && ETHEREUM_FORMAT) ||
    (bitcoin? && BITCOIN_FORMAT)
  end
end
