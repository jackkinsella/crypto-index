module Admin
  class CurrenciesController < AdminController
    def index
      @currencies = action_cache {
        Currency.order(:symbol).to_a
      }
    end
  end
end
