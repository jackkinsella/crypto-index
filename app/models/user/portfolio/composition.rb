class User::Portfolio::Composition < ApplicationRecord
  include Timestamped

  WAIT_INTERVAL = Valuation::RECENT_INTERVAL + 15.minutes

  self.table_name = 'user/portfolio/compositions'

  belongs_to :user_portfolio,
    class_name: 'User::Portfolio', foreign_key: :portfolio_id,
    inverse_of: :compositions

  validates :value_usd,
    numericality: {
      greater_than: 0
    }

  validates :value_btc,
    numericality: {
      greater_than: 0
    }

  validates :value_eth,
    numericality: {
      greater_than: 0
    }

  validates :return_on_investment,
    numericality: true

  validates :tracking_error,
    numericality: true,
    allow_nil: true

  validates :constituents,
    presence: false

  delegate :user, to: :user_portfolio

  def calculate_tracking_error!
    update!(tracking_error: root_mean_squared_error)
  end

  def constituents
    self[:constituents].map { |symbol, amount| [symbol, amount.to_d] }.to_h
  end

  def constituent_weights
    @_constituent_weights ||= begin
      constituent_values_in_usd = constituents.map { |symbol, amount|
        [symbol, Currency.send(symbol).price_usd_at(timestamp) * amount]
      }.to_h

      constituent_values_in_usd.map { |symbol, value_usd|
        [symbol, value_usd / constituent_values_in_usd.values.sum]
      }.to_h
    end
  end

  class MissingIndexAllocationError < StandardError; end

  private

  def root_mean_squared_error
    mean_squared_error**0.5
  end

  # FIXME: This gives answers such as 'infinity' when constituents are empty,
  # suggesting that we need an additional assertion or class-level validation on
  # constituents.
  def mean_squared_error
    index_allocation = Index.m10.allocations.at(timestamp).take

    # FIXME: raise NotImplementedError if Index.count > 1
    raise MissingIndexAllocationError if index_allocation.nil?

    squared_error_sum =
      index_allocation.to_h.reduce(0) { |sum, (symbol, component_weight)|
        constituent_weight = constituent_weights[symbol] || 0

        absolute_error = constituent_weight - component_weight
        relative_error = absolute_error / component_weight

        sum + relative_error**2
      }

    squared_error_sum / constituent_weights.size
  end
end
