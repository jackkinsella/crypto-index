class UpdateMarketTradesToVersion2 < ActiveRecord::Migration[5.2]
  def change
    add_index :market_trades, [:initiator_type, :initiator_id, :base_currency_id, :quote_currency_id], unique: true, name: 'index_market_trades_on_unique_columns'
  end
end
