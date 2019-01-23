class Valuation < ApplicationRecord
  include Timestamped
  include Immutable
  include Valuable

  RECENT_INTERVAL = 30.minutes
  REFERENCE_INTERVAL = 1.week

  immutable if: -> {
    Index.allocations_at?(timestamp)
  }

  belongs_to :currency

  has_one :indicator # rubocop:disable Rails/HasManyOrHasOneDependent

  alias original_indicator indicator
  def indicator
    original_indicator || Indicator.build_missing_for(self)
  end

  has_many :readings, dependent: :nullify

  validates :readings,
    presence: true,
    unless: :stale?

  validates_market_cap allow_nil: false

  validates_price_usd allow_nil: false

  validates_circulating_supply allow_nil: false

  validate do
    if timestamp.present?
      if currency.not_trackable_until?(timestamp)
        errors[:currency] << "is not trackable until #{currency.trackable_at}"
      end

      if currency.rejected_before?(timestamp)
        errors[:currency] << "has been rejected at #{currency.rejected_at}"
      end
    end
  end

  delegate :market_cap_usd_moving_average_24h,
    :price_usd_moving_average_24h,
    :circulating_supply_moving_average_24h,
    :price_change_24h, :price_change_24h_percent,
    to: :indicator, allow_nil: true

  before_validation(prepend: true) do
    assign_values
  end

  def score
    trusted_evaluated_count = trusted_readings.size
    available_count = Reading.for(currency).at(timestamp).size
    "#{trusted_evaluated_count}(#{available_count})"
  end

  private

  def recent?
    timestamp > RECENT_INTERVAL.ago
  end

  def trusted?
    trusted_readings.size.positive?
  end

  def fully_trusted?
    trusted_readings.size == Reading::TRUSTED_SOURCE_NAMES.size
  end

  def trusted_readings
    readings.select(&:trusted?)
  end

  def assign_values
    return if recent? && !fully_trusted?

    if trusted?
      assign_values_from_trusted_readings
    elsif reference_valuation.present?
      assign_values_from_readings_and_reference_valuation
    end
  end

  def assign_values_from_trusted_readings
    self.market_cap_usd = nil
    [:circulating_supply, :price_usd].each do |attribute|
      self[attribute] = trusted_readings.map(&attribute).mean
    end
  end

  def assign_values_from_readings_and_reference_valuation
    self.stale = readings.blank?
    self.market_cap_usd = nil
    self.circulating_supply = reference_valuation.circulating_supply
    self.price_usd =
      readings.map(&:price_usd).mean ||
      reference_valuation.price_usd
  end

  def reference_valuation
    interval = timestamp - REFERENCE_INTERVAL, timestamp
    currency.valuations.between(*interval).asc.last
  end
end
