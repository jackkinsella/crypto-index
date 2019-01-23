module Charting
  module Strategies
    class Index
      def initialize(index)
        @index = index
      end

      def compile(timestamps)
        allocations_for(index, timestamps).map do |allocation|
          [
            allocation.timestamp.to_i * 1_000,
            allocation.value.round(2)
          ]
        end
      end

      private

      attr_reader :index

      def allocations_for(index, timestamps)
        index.allocations.asc.at(timestamps).select(:timestamp, :value)
      end
    end
  end
end
