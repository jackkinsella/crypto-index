class UpdateValuationReadingsToVersion2 < ActiveRecord::Migration[5.2]
  def change
    change_column_null :valuation_readings, :market_cap_usd, true
    change_column_null :valuation_readings, :price_usd, true
    change_column_null :valuation_readings, :circulating_supply, true
  end
end
