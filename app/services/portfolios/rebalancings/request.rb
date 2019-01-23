module Portfolios
  module Rebalancings
    class Request < ApplicationAction
      def initialize(portfolio:)
        @portfolio = portfolio
      end

      def execute!
        return unless portfolio.holdings.exists?
        return unless portfolio.deposits.all?(&:finalized?)

        portfolio.rebalancings.create_with(
          requested_at: Time.now
        ).find_or_create_by!(
          scheduled_at: next_rebalancing_time_for(portfolio)
        )
      end

      def next_rebalancing_time_for(portfolio)
        rebalancing_interval = User::Portfolio::Rebalancing::MONTHLY_INTERVAL
        last_scheduled_at = portfolio.rebalancings.maximum(:scheduled_at)

        if last_scheduled_at.nil?
          next_friday_at_12_utc + (rebalancing_interval - 1.week)
        else
          last_scheduled_at + rebalancing_interval
        end
      end

      def next_friday_at_12_utc
        (Time.now - 36.hours).round_up(resolution: 1.week) + 36.hours
      end

      private

      attr_reader :portfolio
    end
  end
end
