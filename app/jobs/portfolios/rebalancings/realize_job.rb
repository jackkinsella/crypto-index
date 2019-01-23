module Portfolios
  module Rebalancings
    class RealizeJob < ApplicationJob
      def perform
        # FIXME: Standardize handling of time intervals in scopes
        # (see `before`, `after`, `scheduled_before`, ...)
        rebalancings = User::Portfolio::Rebalancing.not_finalized.
          scheduled_after(Time.now.beginning_of_hour - 1.second).
          scheduled_before(Time.now.end_of_hour)

        Realize.execute!(rebalancings: rebalancings)
      end
    end
  end
end
