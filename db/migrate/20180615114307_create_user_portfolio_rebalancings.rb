class CreateUserPortfolioRebalancings < ActiveRecord::Migration[5.2]
  def change
    create_table :user_portfolio_rebalancings do |t|
      t.references :portfolio, null: false, index: true, foreign_key: {to_table: :user_portfolios}
      t.decimal :crypto_index_fee, precision: 32, scale: 12, index: true
      t.datetime :requested_at, null: false, index: true
      t.datetime :scheduled_at, null: false, index: true
      t.datetime :finalized_at, index: true
      t.timestamps null: false, index: true
    end

    add_index :user_portfolio_rebalancings, [:portfolio_id, :scheduled_at], unique: true, name: 'index_user_portfolio_rebalancings_on_unique_columns'
  end
end
