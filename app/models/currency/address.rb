class Currency::Address < ApplicationRecord
  include Categorized
  include Immutable

  self.table_name = 'currency/addresses'

  categories :deposit, :market_inbound, :market_outbound,
    :user_inbound, :user_outbound, :withdrawal

  BITCOIN_FORMAT = /\A[13][a-km-zA-HJ-NP-Z1-9]{33}\z/
  ETHEREUM_FORMAT = /\A0x[0-9A-Fa-f]{40}\z/

  belongs_to :owner, polymorphic: true

  belongs_to :currency

  has_many :incoming_transactions,
    class_name: 'Currency::Transaction', inverse_of: :to_address,
    foreign_key: :to_address_id, dependent: :restrict_with_exception

  has_many :outgoing_transactions,
    class_name: 'Currency::Transaction', inverse_of: :from_address,
    foreign_key: :from_address_id, dependent: :restrict_with_exception

  validates :owner_type,
    inclusion: {in: ['Market', 'User', 'User::Account']}

  validates :value,
    presence: true,
    uniqueness: true

  validates :key_path,
    uniqueness: true,
    allow_nil: -> { owner_type == 'Market' }

  validates :disabled_at,
    presence: false

  validate :category_is_suitable,
    :currency_is_supported,
    :address_has_valid_format,
    :address_has_valid_checksum

  def self.generate_for!(owner:, currency:, category:)
    raise ArgumentError unless [:deposit, :withdrawal].include?(category)

    Retriable.retriable do
      generator = Blockchains::AddressGenerator.new(
        currency: currency,
        number: Currency::Address.unscoped.count
      )

      create!(
        owner: owner,
        currency: currency,
        category: category,
        value: generator.address,
        key_path: generator.key_path
      )
    end
  end

  def user
    case owner_type
    when 'User' then owner
    when 'User::Account' then owner.user
    end
  end

  def disabled?
    disabled_at?
  end

  def bitcoin?
    currency == Currency.btc
  end

  def ethereum?
    currency == Currency.eth
  end

  def to_s
    value.downcase
  end

  private

  def category_is_suitable
    return if category_suitable_for_market? ||
      category_suitable_for_user? ||
      category_suitable_for_user_account?

    errors[:category] << 'is unsuitable'
  end

  def category_suitable_for_market?
    category.start_with?('market_') && owner_type == 'Market'
  end

  def category_suitable_for_user?
    category.start_with?('user_') && owner_type == 'User'
  end

  def category_suitable_for_user_account?
    %w[deposit withdrawal].include?(category) && owner_type == 'User::Account'
  end

  def currency_is_supported
    errors[:currency] << 'is not yet supported' unless ethereum?
  end

  def address_has_valid_format
    return if value.nil? || value.match?(value_format)
    errors[:value] << 'is invalid'
  end

  def address_has_valid_checksum
    service = {bitcoin: Bitcoin, ethereum: Eth::Utils}[currency.to_sym]
    return if service.valid_address?(value)

    errors[:value] << 'has an invalid checksum'
  end

  def value_format
    (ethereum? && ETHEREUM_FORMAT) ||
    (bitcoin? && BITCOIN_FORMAT)
  end
end
