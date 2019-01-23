class CurrenciesController < ApplicationController
  def index
    @currencies = action_cache {
      Currency.current_by_market_cap.to_a
    }
  end

  def show
    @currency, @data = action_cache(:id) {
      currency = Currency.find_by!(name: params[:id])
      [currency, Charting::Data.for(currency).compile]
    }
  end
end
