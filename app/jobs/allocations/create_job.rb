module Allocations
  class CreateJob < ApplicationJob
    def perform(from_date: nil, to_date: nil, indexes: nil)
      Allocations::Create.new(
        from_date: (Date.parse(from_date) if from_date.present?),
        to_date: (Date.parse(to_date) if to_date.present?),
        indexes: [Index.m10] # FIXME: Include other indexes again
      ).execute!
    end
  end
end
