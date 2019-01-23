class CreateUserPortfolioCompositions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_portfolio_compositions do |t|
      t.references :portfolio, null: false, index: true, foreign_key: {to_table: :user_portfolios}
      t.decimal :value_usd, precision: 32, scale: 12, null: false, index: true
      t.decimal :value_btc, precision: 32, scale: 12, null: false, index: true
      t.decimal :value_eth, precision: 32, scale: 12, null: false, index: true
      t.decimal :return_on_investment, precision: 32, scale: 12, null: false, index: true
      t.decimal :tracking_error, precision: 32, scale: 12, null: false, index: true
      t.jsonb :constituents, null: false, default: [], index: {using: :gin}
      t.datetime :timestamp, null: false, index: true
      t.timestamps null: false, index: true
    end

    add_index :user_portfolio_compositions, [:portfolio_id, :timestamp], unique: true, name: 'index_user_portfolio_compositions_on_unique_columns'
  end
end
