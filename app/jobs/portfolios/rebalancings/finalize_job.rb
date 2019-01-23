module Portfolios
  module Rebalancings
    class FinalizeJob < ApplicationJob
      def perform
        rebalancings =
          User::Portfolio::Rebalancing.not_finalized.select(&:realized?)

        Finalize.execute!(rebalancings: rebalancings)
      end
    end
  end
end
