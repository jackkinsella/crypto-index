module Valuations
  class CreateJob < ApplicationJob
    def perform(from_date: nil, to_date: nil, currencies: nil)
      Valuations::Create.new(
        from_date: (Date.parse(from_date) if from_date.present?),
        to_date: (Date.parse(to_date) if to_date.present?),
        currencies: (Currency.where(symbol: currencies) if currencies.present?)
      ).execute!
    end
  end
end
