class Index::Component < ApplicationRecord
  include Immutable

  self.table_name = 'index/components'

  belongs_to :allocation

  belongs_to :currency

  validates :weight,
    presence: true

  delegate :index, :timestamp, to: :allocation

  delegate :symbol, :name, :title, to: :currency

  delegate_missing_to :valuation

  def valuation
    currency.valuations.at(timestamp).take
  end

  def weight_percent
    weight.as_percent
  end

  def weighted_price_usd
    weight * price_usd
  end

  def centering
    1 - (weight - index.centered_component_weight).abs
  end

  def sanitized_attributes
    currency.sanitized_attributes.merge(
      weight: weight,
      weight_percent: weight_percent
    )
  end

  def to_h
    {symbol => weight}
  end
end
