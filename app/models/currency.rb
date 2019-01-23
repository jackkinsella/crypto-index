class Currency < ApplicationRecord
  include Nameable
  include Availability

  SYMBOLS = symbols_for(:currencies)
  PLATFORMS = %w[ethereum neo omni].freeze

  has_one :current_valuation, -> { current_for(:currency) },
    class_name: 'Valuation', inverse_of: :currency

  has_many :valuations, dependent: :restrict_with_exception

  has_many :valuation_readings,
    class_name: 'Valuation::Reading',
    inverse_of: :currency, dependent: :restrict_with_exception

  has_many :components,
    class_name: 'Index::Component',
    inverse_of: :currency, dependent: :restrict_with_exception

  has_many :allocations, through: :components, class_name: 'Index::Allocation'

  has_many :indexes, -> { distinct }, through: :allocations

  has_many :addresses, dependent: :restrict_with_exception

  has_many :transactions, dependent: :restrict_with_exception

  has_many :trades_as_base,
    class_name: 'Market::Trade', inverse_of: :base_currency,
    dependent: :restrict_with_exception

  has_many :trades_as_quote,
    class_name: 'Market::Trade', inverse_of: :quote_currency,
    dependent: :restrict_with_exception

  has_many :trades_as_fee,
    class_name: 'Market::Trade', inverse_of: :fee_currency,
    dependent: :restrict_with_exception

  # has_many :accounts
  # has_many :holdings
  # has_many :portfolios, through: :holdings

  validates :symbol,
    presence: true,
    uniqueness: true,
    inclusion: {in: SYMBOLS}

  validates :name,
    presence: true,
    uniqueness: true,
    format: {with: NAME_FORMAT}

  validates :title,
    presence: true,
    length: {maximum: MAXIMUM_LENGTH}

  validates :platform,
    inclusion: {in: PLATFORMS, allow_nil: true}

  validates :maximum_supply,
    numericality: {
      greater_than: 0
    },
    allow_nil: true

  delegate :start_time, :end_time, to: :valuations

  delegate :market_cap_usd, :price_usd, :circulating_supply,
    :market_cap_usd_moving_average_24h, :price_usd_moving_average_24h,
    :circulating_supply_moving_average_24h,
    :price_change_24h, :price_change_24h_percent,
    to: :current_valuation, allow_nil: true

  scope :current_by_market_cap, -> {
    not_rejected.includes(current_valuation: :indicator).
      order('valuations.market_cap_usd DESC').
      where('valuations.timestamp >= ?',
        Valuation.group(:currency_id).maximum(:timestamp).values.min)
  }

  def price_usd_at(time)
    valuations.at(time.round_down).take&.price_usd
  end

  def price_btc_at(time)
    price_usd_at(time) / Currency.btc.price_usd_at(time) rescue nil
  end

  def price_eth_at(time)
    price_usd_at(time) / Currency.eth.price_usd_at(time) rescue nil
  end

  def sanitized_attributes
    super.merge(
      'symbol' => symbol,
      'name' => name,
      'title' => title,
      'market_cap_usd' => market_cap_usd,
      'price_usd' => price_usd,
      'circulating_supply' => circulating_supply,
      'price_change_24h' => price_change_24h,
      'price_change_24h_percent' => price_change_24h_percent
    )
  end

  def to_s
    symbol
  end
end
