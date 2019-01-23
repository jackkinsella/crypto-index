class User::Portfolio::CurrencyHoldingsController < ApplicationController
  before_action :require_authentication, :require_level_1

  def index
    @holdings = current_user.holdings.to_a
  end
end
