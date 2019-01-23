class Valuation::Reading < ApplicationRecord
  include Timestamped
  include Immutable
  include Valuable

  self.table_name = 'valuation/readings'

  SOURCE_NAMES = %w[
    coin_market_cap
    crypto_compare
    cryptowatch
    on_chain_fx
  ].freeze

  TRUSTED_SOURCE_NAMES = %w[
    coin_market_cap
    on_chain_fx
  ].freeze

  belongs_to :currency

  belongs_to :valuation, optional: true

  validates_market_cap allow_nil: true

  validates_price_usd allow_nil: true

  validates_circulating_supply allow_nil: true

  validates :source_name,
    presence: true,
    inclusion: SOURCE_NAMES

  validates :source_data,
    presence: true

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

  scope :from_source, ->(name) { where(source_name: name) }

  scope :evaluated, -> { where.not(valuation_id: nil) }

  scope :trusted, -> {
    where(source_name: TRUSTED_SOURCE_NAMES).complete
  }

  def trusted?
    TRUSTED_SOURCE_NAMES.include?(source_name) && complete?
  end
end
