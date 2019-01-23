module Portfolios
  class UpdateJob < ApplicationJob
    def perform(trades:)
      Update.execute!(trades: trades)
    end
  end
end
