class CreateValuations < ActiveRecord::Migration[5.2]
  def change
    create_table :valuations do |t|
      t.references :currency, null: false, index: true, foreign_key: true
      t.decimal :market_cap_usd, precision: 32, scale: 12, null: false, index: true
      t.decimal :price_usd, precision: 32, scale: 12, null: false, index: true
      t.decimal :circulating_supply, precision: 32, scale: 12, null: false, index: true
      t.datetime :timestamp, null: false, index: true
      t.timestamps null: false, index: true
    end

    add_index :valuations, [:currency_id, :timestamp], unique: true, name: 'index_valuations_on_unique_columns'
  end
end
