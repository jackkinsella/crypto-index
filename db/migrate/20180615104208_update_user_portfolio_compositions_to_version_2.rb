class UpdateUserPortfolioCompositionsToVersion2 < ActiveRecord::Migration[5.2]
  def change
    change_column_default :user_portfolio_compositions, :constituents, from: {}, to: []
  end
end
