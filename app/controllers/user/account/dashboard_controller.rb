class User::Account::DashboardController < ApplicationController
  before_action :require_authentication, :require_level_1

  def show
    @deposits_count = current_user.deposits.count
    @rebalancings_count = current_user.rebalancings.finalized.count
    @withdrawals_count = current_user.withdrawals.finalized.count
    @performance_values_usd =
      Charting::Data.for(current_user.portfolio).compile.to_h
    @portfolio_value_usd = current_user.portfolio.value_usd rescue nil
    @portfolio_value_eth = current_user.portfolio.value_eth rescue nil
    @portfolio_return_on_investment =
      current_user.portfolio.return_on_investment rescue nil
    @portfolio_last_rebalanced_at_in_words = time_ago_in_words(
      current_user.portfolio.rebalancings.maximum(:finalized_at)
    ) rescue nil
  end
end
