module Holdings
  class Update < ApplicationAction
    def initialize(portfolio:, currency:)
      @portfolio = portfolio
      @currency = currency
    end

    def execute!
      ApplicationRecord.transaction do
        assessment = Holdings::Assessment.new(
          portfolio: portfolio, timestamp: Time.now.round_up
        )

        holding = find_or_create_holding!
        holding.update!(size: assessment.constituents[currency.symbol])
      end
    end

    private

    attr_reader :portfolio, :currency

    def find_or_create_holding!
      User::Holding.create_with(size: 0).
        find_or_create_by!(
          portfolio: portfolio,
          currency: currency
        )
    end
  end
end
