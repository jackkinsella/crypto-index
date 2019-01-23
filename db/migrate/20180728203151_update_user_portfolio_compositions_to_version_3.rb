class UpdateUserPortfolioCompositionsToVersion3 < ActiveRecord::Migration[5.2]
  def change
    change_column_null :'user/portfolio/compositions', :tracking_error, true
  end
end
