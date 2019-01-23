class CreateValuationReadings < ActiveRecord::Migration[5.2]
  def change
    create_table :valuation_readings do |t|
      t.references :currency, null: false, index: true, foreign_key: true
      t.references :valuation, index: true, foreign_key: true
      t.decimal :market_cap_usd, precision: 32, scale: 12, null: false
      t.decimal :price_usd, precision: 32, scale: 12, null: false
      t.decimal :circulating_supply, precision: 32, scale: 12, null: false
      t.string :source_name, null: false, index: true
      t.jsonb :source_data, null: false, default: {}
      t.datetime :timestamp, null: false, index: true
      t.timestamps null: false, index: true
    end

    add_index :valuation_readings, [:currency_id, :timestamp, :source_name], unique: true, name: 'index_valuation_readings_on_unique_columns'
  end
end
