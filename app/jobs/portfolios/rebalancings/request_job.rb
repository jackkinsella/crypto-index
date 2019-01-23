module Portfolios
  module Rebalancings
    class RequestJob < ApplicationJob
      def perform
        User::Portfolio.find_each do |portfolio|
          Request.execute!(portfolio: portfolio) if portfolio.need_rebalancing?
        end
      end
    end
  end
end
