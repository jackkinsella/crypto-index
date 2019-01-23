module Portfolios
  module Rebalancings
    class Realize < ApplicationAction
      def initialize(rebalancings:)
        @rebalancings = Array.wrap(rebalancings)
      end

      def execute!
        rebalancings.each do |rebalancing|
          realize(rebalancing)
        end
      end

      private

      attr_reader :rebalancings

      def realize(rebalancing)
        return if rebalancing.initiated?

        trades = Trading::Assembly::Rebalancing.execute!(
          rebalancing: rebalancing
        )

        ApplicationRecord.transaction do
          trades.each(&:save!)
        end

        trades.each do |trade|
          Trading::Orders::CreateJob.perform_later(trade: trade)
        end
      end
    end
  end
end
