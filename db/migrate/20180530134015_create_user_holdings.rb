class CreateUserHoldings < ActiveRecord::Migration[5.2]
  def change
    create_table :user_holdings do |t|
      t.references :portfolio, null: false, index: true, foreign_key: {to_table: :user_portfolios}
      t.references :currency, null: false, index: true, foreign_key: true
      t.decimal :size, precision: 32, scale: 12, null: false, index: true
    end

    add_index :user_holdings, [:portfolio_id, :currency_id], unique: true, name: 'index_user_holdings_on_unique_columns'
  end
end
