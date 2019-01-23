class UpdateValuationIndicatorsToVersion2 < ActiveRecord::Migration[5.2]
  def up
    drop_view :valuation_indicators
    create_view :valuation_indicators, version: 2, materialized: true

    add_index :valuation_indicators, :valuation_id, unique: true
  end

  def down
    drop_view :valuation_indicators, materialized: true
    create_view :valuation_indicators, version: 1
  end
end
