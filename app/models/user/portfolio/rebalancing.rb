class User::Portfolio::Rebalancing < ApplicationRecord
  WEEKLY_INTERVAL = 1.week
  BIWEEKLY_INTERVAL = 2.weeks
  MONTHLY_INTERVAL = 4.weeks
  QUARTERLY_INTERVAL = 12.weeks

  self.table_name = 'user/portfolio/rebalancings'

  belongs_to :user_portfolio,
    class_name: 'User::Portfolio', foreign_key: :portfolio_id,
    inverse_of: :deposits

  has_many :trades,
    class_name: 'Market::Trade', as: :initiator,
    inverse_of: :initiator, dependent: :restrict_with_exception

  validates :crypto_index_fee,
    numericality: {
      greater_than_or_equal_to: 0
    },
    allow_nil: true

  validates :requested_at,
    presence: true

  validates :scheduled_at,
    presence: true,
    time: {
      resolution: 1.hour,
      after: Time.parse('3 Jan 2009'),
      before: Time.now + 1.month
    }

  validates :finalized_at,
    presence: false

  alias_attribute :portfolio, :user_portfolio

  delegate :user, to: :user_portfolio

  scope :scheduled_before, ->(time) { where('scheduled_at <= ?', time) }
  scope :scheduled_after, ->(time) { where('scheduled_at > ?', time) }

  scope :finalized, -> { where.not(finalized_at: nil) }
  scope :not_finalized, -> { where(finalized_at: nil) }

  def crypto_index_fee_currency
    Currency.bnb # TODO: This will be extended once we add more markets
  end

  def value
    crypto_index_fee || 0 # TODO: Refactor (can it be removed already?)
  end

  def confirmed_at_in_words
    time_ago_in_words(finalized? ? finalized_at : scheduled_at) # TODO: Refactor
  end

  def initiated?
    trades.exists?
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
        type: :rebalancing,
        id: id,
        portfolio_id: user_portfolio.id,
        scheduled_at: scheduled_at
      }.to_json
    )
  end

  def sanitized_attributes
    super.merge(
      'confirmed_at_in_words' => confirmed_at_in_words
    )
  end
end
