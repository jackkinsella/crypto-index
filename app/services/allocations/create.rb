module Allocations
  class Create < ApplicationAction
    def initialize(from_date: nil, to_date: nil, indexes: nil)
      @from_date = from_date || to_date || Date.today
      @to_date = to_date || @from_date
      @indexes = Array(indexes || Index.order(:symbol))
    end

    def execute!
      (from_date..to_date).to_a.each do |date|
        indexes.each do |index|
          create_allocations_for!(date, index)
        end
      end
    end

    private

    attr_reader :from_date, :to_date, :indexes

    def create_allocations_for!(date, index)
      Time.partition(date, [date.end_of_day, Time.now].min).each do |timestamp|
        create_allocation_for!(timestamp, index)
      end
    end

    def create_allocation_for!(timestamp, index)
      return if missing_valuations_at?(timestamp)

      currencies = Currency.available_at(timestamp).
        trackable_before(timestamp - 23.hours).pluck(:id) &
          minimum_timestamps.select { |_, time|
            time + 23.hours <= timestamp
          }.keys

      indicators = Valuation::Indicator.includes(valuation: :currency).
        where(valuations: {currency: currencies}).
        at(timestamp).yield_self { |scope|
          build_components(scope, index)
        }

      return if indicators.any? { |indicator|
        indicator.market_cap_usd_moving_average_24h.nil?
      }

      begin
        Index::Allocation.create_with(
          components: indicators.map { |indicator|
            indicator.currency.components.build(
              weight: indicator.market_cap_usd_moving_average_24h
            )
          }
        ).find_or_create_by!(
          index: index,
          timestamp: timestamp
        )
      rescue ActiveRecord::RecordNotUnique
        Index::Allocation.find_by(index: index, timestamp: timestamp)
      end
    end

    def build_components(scope, index)
      case index.to_sym
      when :market10 then scope.by_market_cap_over_24h.limit(10)
      when :'market10-even' then scope.by_market_cap_over_24h.limit(10)
      when :market20 then scope.by_market_cap_over_24h.limit(20)
      end
    end

    def missing_valuations_at?(timestamp)
      required_valuation_count = Currency.available_at(timestamp).where(
        id: minimum_timestamps.select { |_, time| time <= timestamp }.keys
      ).count

      Valuation.at(timestamp).count != required_valuation_count ||
      Valuation::Indicator.at(timestamp).count != required_valuation_count
    end

    def minimum_timestamps
      @_minimum_timestamps ||=
        Valuation.group(:currency_id).minimum(:timestamp)
    end
  end
end
