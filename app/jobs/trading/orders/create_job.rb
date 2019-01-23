module Trading
  module Orders
    class CreateJob < ApplicationJob
      queue_as :traders

      def perform(trade:)
        return if trade.completed?

        Create.execute!(trade: trade)
      end
    end
  end
end
