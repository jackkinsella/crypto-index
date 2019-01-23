class Index::Allocation < ApplicationRecord
  include Timestamped
  include Immutable

  self.table_name = 'index/allocations'

  belongs_to :index

  has_many :components, dependent: :destroy

  validates :value,
    numericality: {
      greater_than: 0
    }

  validate do
    unless components.size == index.number_of_components
      errors[:components] << "should be exactly #{index.number_of_components}"
    end
  end

  validate do
    deviation = 1 - components.sum(&:weight)
    unless deviation.abs < 1e-8
      errors[:components] << 'must have a total weight of 1.0'
    end
  end

  before_validation do
    normalize_component_weights
    restrict_component_weights
  end

  before_validation do
    assign_value
  end

  def self.at_genesis_date(index)
    index.allocations.at(CryptoIndex::GENESIS_DATE).take
  end

  def to_h
    components.includes(:currency).map(&:to_h).reduce(:merge)
  end

  class NoGenesisAllocationError < StandardError; end

  private

  def normalize_component_weights
    total_weight = components.sum(&:weight)

    components.each do |component|
      component.weight /= total_weight
    end
  end

  def restrict_component_weights
    ordered_components = components.to_a
    count = components.size

    (0...count).each do |i|
      ordered_components[i...count] =
        ordered_components[i...count].sort_by(&:centering)

      ordered_components[i].weight = [
        [index.minimum_component_weight, ordered_components[i].weight].max,
        index.maximum_component_weight
      ].min

      remaining_weight = ordered_components[(i + 1)...count].sum(&:weight)

      weight_correction = (remaining_weight /
        (1 - ordered_components.sum(&:weight) + remaining_weight))

      ((i + 1)...count).each do |j|
        ordered_components[j].weight /= weight_correction
      end
    end
  end

  def assign_value
    if timestamp == CryptoIndex::GENESIS_DATE
      self.value = 100
    else
      genesis_allocation = self.class.at_genesis_date(index) ||
        (raise NoGenesisAllocationError, <<~TEXT)
          Missing allocation for #{index} at #{CryptoIndex::GENESIS_DATE.to_time}
        TEXT

      self.value = 100 * components.sum(&:market_cap_usd) /
        genesis_allocation.components.sum(&:market_cap_usd)
    end
  end
end
