module Accounts
  module Deposits
    class TrackJob < ApplicationJob
      def perform
        Track.execute!
      end
    end
  end
end
