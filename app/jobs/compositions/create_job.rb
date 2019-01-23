module Compositions
  class CreateJob < ApplicationJob
    def perform
      User::Portfolio.order(:id).find_each do |portfolio|
        Compositions::Create.execute!(portfolio: portfolio)
      end
    end
  end
end
