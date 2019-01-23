class Market::Trade < ApplicationRecord
  include Nameable
  include Categorized
  include Identifiable

  SYMBOLS = Currency::SYMBOLS.
    map { |symbol| ["#{symbol}BTC", "#{symbol}ETH"] }.flatten.freeze

  self.table_name = 'market/trades'

  categories :service, :user

  belongs_to :market

  belongs_to :initiator, polymorphic: true

  belongs_to :base_currency,
    class_name: 'Currency', inverse_of: :trades_as_base

  belongs_to :quote_currency,
    class_name: 'Currency', inverse_of: :trades_as_quote

  belongs_to :fee_currency,
    class_name: 'Currency', inverse_of: :trades_as_fee, optional: true

  validates :initiator_type,
    inclusion: {
      in: [
        'User::Account::Deposit',
        'User::Account::Withdrawal',
        'User::Portfolio::Rebalancing'
      ]
    }

  validates :symbol,
    presence: true,
    inclusion: {in: SYMBOLS}

  validates :order_side,
    presence: true,
    inclusion: {in: %w[BUY SELL]}

  validates :order_type,
    presence: true,
    inclusion: {in: %w[MARKET]}

  validates :amount,
    numericality: {
      greater_than: 0
    }

  validates :price,
    numericality: {
      greater_than: 0
    },
    allow_nil: true

  validates :fee,
    numericality: true,
    allow_nil: true

  validates :details,
    presence: false

  validates :started_at,
    presence: false

  validates :completed_at,
    presence: false

  before_validation do
    self.symbol = "#{base_currency}#{quote_currency}"
  end

  scope :completed, -> { where.not(completed_at: nil) }

  def from_currency
    case order_side
    when 'BUY' then quote_currency
    when 'SELL' then base_currency
    end
  end

  def to_currency
    case order_side
    when 'BUY' then base_currency
    when 'SELL' then quote_currency
    end
  end

  def from_amount
    case order_side
    when 'BUY' then cost
    when 'SELL' then amount
    end
  end

  def to_amount
    case order_side
    when 'BUY' then amount
    when 'SELL' then cost
    end
  end

  def cost
    amount * price rescue nil
  end

  def result
    {
      from_currency.to_s => -from_amount,
      to_currency.to_s => to_amount
    }
  end

  def started?
    started_at?
  end

  def pending?
    started? && !completed?
  end

  def completed?
    completed_at?
  end

  def start
    self.started_at = Time.now unless started?
  end

  def start!
    start && save!
  end

  def complete
    self.completed_at = Time.now unless completed?
  end

  def complete!
    complete && save!
  end

  def service?
    category == 'service'
  end

  def external_id
    code =
      case market
      when Market.binance
        details['clientOrderId']
      else
        raise NotImplementedError
      end

    return nil if code.nil?

    @_external_id ||= Digest::SHA256.new.hexdigest(
      {
        type: :trade,
        id: id,
        market_id: market.id,
        code: code
      }.to_json
    )
  end

  def to_s
    "#{order_type} #{order_side} " \
    "#{amount} #{base_currency}#{quote_currency} @ #{price}"
  end
end
