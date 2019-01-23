module Compositions
  class Create < ApplicationAction
    def initialize(portfolio:)
      @portfolio = portfolio
    end

    def execute!
      create_compositions_for!
    end

    private

    attr_reader :portfolio

    def create_compositions_for!
      return unless portfolio.deposits.exists?

      start_time = [
        portfolio.start_time,
        (portfolio.end_time + 1.hour rescue nil)
      ].compact.max

      end_time = Time.now - User::Portfolio::Composition::WAIT_INTERVAL

      Time.partition(start_time, end_time).each do |timestamp|
        next if data_missing?(timestamp)

        create_composition_for!(timestamp)
      end
    end

    def create_composition_for!(timestamp)
      assessment = Holdings::Assessment.new(
        portfolio: portfolio, timestamp: timestamp
      )

      composition = User::Portfolio::Composition.create_with(
        value_usd: assessment.value_usd,
        value_btc: assessment.value_btc,
        value_eth: assessment.value_eth,
        return_on_investment:
          assessment.value_usd / portfolio.deposits.sum(&:net_value_usd) - 1,
        constituents: assessment.constituents
      ).find_or_create_by!(
        user_portfolio: portfolio,
        timestamp: timestamp
      )

      composition.calculate_tracking_error!
    end

    def data_missing?(timestamp)
      !Index::Allocation.at(timestamp).exists?
    end
  end
end
