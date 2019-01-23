class CreateValuationIndicators < ActiveRecord::Migration[5.2]
  def change
    create_view :valuation_indicators
  end
end
