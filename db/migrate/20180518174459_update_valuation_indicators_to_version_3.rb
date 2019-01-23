class UpdateValuationIndicatorsToVersion3 < ActiveRecord::Migration[5.2]
  def change
    update_view :valuation_indicators, version: 3, revert_to_version: 2, materialized: true
  end
end
