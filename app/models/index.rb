class Index < ApplicationRecord
  include Nameable

  SYMBOLS = symbols_for(:indexes)

  has_one :current_allocation, -> { current_for(:index) },
    class_name: 'Index::Allocation', inverse_of: :index

  has_many :allocations, dependent: :restrict_with_exception

  has_many :components, through: :current_allocation

  has_many :currencies, -> { distinct }, through: :components

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

  delegate :value, to: :current_allocation, allow_nil: true

  delegate :start_time, :end_time, to: :allocations

  delegate_missing_to :config

  def self.allocations_at?(timestamp)
    Allocation.at(timestamp).exists?
  end

  def config
    @_config ||= Config.new(name)
  end

  def percentage
    100
  end

  def sanitized_attributes
    super.merge(
      'symbol' => symbol,
      'name' => name,
      'percentage' => percentage,
      'title' => title,
      'description' => description
    )
  end

  def to_s
    symbol
  end
end
