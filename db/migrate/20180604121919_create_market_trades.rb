class CreateMarketTrades < ActiveRecord::Migration[5.2]
  def change
    create_table :market_trades do |t|
      t.references :market, null: false, index: true, foreign_key: true
      t.references :initiator, null: false, index: true, polymorphic: true
      t.references :base_currency, null: false, index: true, foreign_key: {to_table: :currencies}
      t.references :quote_currency, null: false, index: true, foreign_key: {to_table: :currencies}
      t.references :fee_currency, index: true, foreign_key: {to_table: :currencies}
      t.string :symbol, null: false, index: true
      t.string :category, null: false, index: true
      t.string :order_side, null: false, index: true
      t.string :order_type, null: false, index: true
      t.decimal :amount, precision: 32, scale: 12, null: false, index: true
      t.decimal :price, precision: 32, scale: 12, index: true
      t.decimal :fee, precision: 32, scale: 12, index: true
      t.jsonb :details, null: false, default: {}, index: {using: :gin}
      t.datetime :started_at, index: true
      t.datetime :completed_at, index: true
      t.timestamps null: false, index: true
    end
  end
end
